--- allows you to send messages of unlimited length over the addon comm channels.
-- It'll automatically split the messages into multiple parts and rebuild them on the receiving end.\\
-- **ChatThrottleLib** is of course being used to avoid being disconnected by the server.

-- **DiesalComm** can be embeded into your addon, either explicitly by calling DiesalComm:Embed(MyAddon) or by 
-- specifying it as an embeded library in your AceAddon. All functions will be available on your addon object
-- and can be accessed directly, without having to explicitly call AceComm itself.\\
-- It is recommended to embed AceComm, otherwise you'll have to specify a custom `self` on all calls you
-- make into DiesalComm.
-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: LibStub, DEFAULT_CHAT_FRAME, geterrorhandler, RegisterAddonMessagePrefix

-- $Id: AceComm-3.0.lua 1107 2014-02-19 16:40:32Z nevcairiel $
-- ~~| Initialize library |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local MAJOR, MINOR = "DiesalComm-1.0", 1
local DiesalComm, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not DiesalComm then return end

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
local CTL = assert(ChatThrottleLib, "DiesalComm-1.0 requires ChatThrottleLib")
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local type, next, pairs, tostring = type, next, pairs, tostring
local strsub, strfind = string.sub, string.find
local match = string.match
local tinsert, tconcat = table.insert, table.concat
local error, assert = error, assert
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local Ambiguate = Ambiguate
-- ~~| DiesalComm Values |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DiesalComm.embeds 						= DiesalComm.embeds or {}
DiesalComm.msg_spool 					= DiesalComm.msg_spool or {} 

local COMM_MODES = {'single','first','next','last'}
local HEADER_SIZE = 14
local HEADER_FORMAT = '%[%x%x:%x%x%x%x:%x%x%x%x%]'

local MAX_CHUNK_SIZE = 240


--- Register for Addon Traffic on a specified prefix
-- @param prefix A printable character (\032-\255) classification of the message (typically AddonName or AddonNameEvent), max 16 characters
-- @param method Callback to call on message reception: Function reference, or method name (string) to call on self. Defaults to "OnCommReceived"
function DiesalComm:RegisterComm(prefix, method)
	if method == nil then	method = "OnCommReceived"	end
	if #prefix > 15 then error("AceComm:RegisterComm(prefix,method): prefix length is limited to 15 characters") end
	RegisterAddonMessagePrefix(prefix)

	return DiesalComm.RegisterCallback(self, prefix, method)
end



local function formatValue(num,len)
  num = format('%X',num)
  for i = 1, len - #num do
    num = "0"..num
  end
  return num  
end


local function encodeHeader(mode, chunk ,totalChunks )	
	return '['..formatValue(mode,2)..':'..formatValue(chunk,4)..':'..formatValue(totalChunks,4)..']'	
end
local function decodeHeader()
	
	
end

--- Send a message over the Addon Channel
-- @param prefix A printable character (\032-\255) classification of the message (typically AddonName or AddonNameEvent)
-- @param text Data to send, nils (\000) not allowed. Any length.
-- @param channel Addon channel, e.g. "RAID", "GUILD", etc; see SendAddonMessage API
-- @param target Destination for some distributions; see SendAddonMessage API
-- @param callbackFn OPTIONAL: callback function to be called as each chunk is sent. receives 3 args: the user supplied arg (see next), the number of bytes sent so far, and the number of bytes total to send.
-- @param callbackArg: OPTIONAL: first arg to the callback function. nil will be passed if not specified.
-- @param prio OPTIONAL: ChatThrottleLib priority, "BULK", "NORMAL" or "ALERT". Defaults to "NORMAL".
function AceComm:SendCommMessage(prefix, text, channel, target, callbackFn, callbackArg, prio)
	prio = prio or "NORMAL"	
	if type(prefix)~="string" and type(text)~="string" and type(channel)~="string" and (target==nil or type(target)~="string")	and	(prio~="BULK" or prio~="NORMAL" or prio~="ALERT")  then
		error('Usage: SendCommMessage(addon, "prefix", "text", "channel"[, "target"[, callbackFn, callbackarg[, "prio"]]])', 2)
	end

	local textlen = #text		
	local ctlCallback = callbackFn and function(sent) return callbackFn(callbackArg, sent, textlen)	end or nil
		
		

	if textlen <= MAX_CHUNK_SIZE then -- fits all in one message
		text = '[0:0000:0000]'..text
		CTL:SendAddonMessage(prio, prefix, text, channel, target, nil, ctlCallback, textlen)
	else
		-- first part
		local chunk = strsub(text, 1, maxtextlen)
		CTL:SendAddonMessage(prio, prefix, MSG_MULTI_FIRST..chunk, distribution, target, queueName, ctlCallback, maxtextlen)

		-- continuation
		local pos = 1+maxtextlen

		while pos+maxtextlen <= textlen do
			chunk = strsub(text, pos, pos+maxtextlen-1)
			CTL:SendAddonMessage(prio, prefix, MSG_MULTI_NEXT..chunk, distribution, target, queueName, ctlCallback, pos+maxtextlen-1)
			pos = pos + maxtextlen
		end

		-- final part
		chunk = strsub(text, pos)
		CTL:SendAddonMessage(prio, prefix, MSG_MULTI_LAST..chunk, distribution, target, queueName, ctlCallback, textlen)
	end
end


----------------------------------------
-- Message receiving
----------------------------------------

do
	local compost = setmetatable({}, {__mode = "k"})
	local function new()
		local t = next(compost)
		if t then 
			compost[t]=nil
			for i=#t,3,-1 do	-- faster than pairs loop. don't even nil out 1/2 since they'll be overwritten
				t[i]=nil
			end
			return t
		end
		
		return {}
	end
	
	local function lostdatawarning(prefix,sender,where)
		DEFAULT_CHAT_FRAME:AddMessage(MAJOR..": Warning: lost network data regarding '"..tostring(prefix).."' from '"..tostring(sender).."' (in "..where..")")
	end

	function AceComm:OnReceiveMultipartFirst(prefix, message, distribution, sender)
		local key = prefix.."\t"..distribution.."\t"..sender	-- a unique stream is defined by the prefix + distribution + sender
		local spool = AceComm.multipart_spool
		
		--[[
		if spool[key] then 
			lostdatawarning(prefix,sender,"First")
			-- continue and overwrite
		end
		--]]
		
		spool[key] = message  -- plain string for now
	end

	function AceComm:OnReceiveMultipartNext(prefix, message, distribution, sender)
		local key = prefix.."\t"..distribution.."\t"..sender	-- a unique stream is defined by the prefix + distribution + sender
		local spool = AceComm.multipart_spool
		local olddata = spool[key]
		
		if not olddata then
			--lostdatawarning(prefix,sender,"Next")
			return
		end

		if type(olddata)~="table" then
			-- ... but what we have is not a table. So make it one. (Pull a composted one if available)
			local t = new()
			t[1] = olddata    -- add old data as first string
			t[2] = message    -- and new message as second string
			spool[key] = t    -- and put the table in the spool instead of the old string
		else
			tinsert(olddata, message)
		end
	end

	function AceComm:OnReceiveMultipartLast(prefix, message, distribution, sender)
		local key = prefix.."\t"..distribution.."\t"..sender	-- a unique stream is defined by the prefix + distribution + sender
		local spool = AceComm.multipart_spool
		local olddata = spool[key]
		
		if not olddata then
			--lostdatawarning(prefix,sender,"End")
			return
		end

		spool[key] = nil
		
		if type(olddata) == "table" then
			-- if we've received a "next", the spooled data will be a table for rapid & garbage-free tconcat
			tinsert(olddata, message)
			AceComm.callbacks:Fire(prefix, tconcat(olddata, ""), distribution, sender)
			compost[olddata] = true
		else
			-- if we've only received a "first", the spooled data will still only be a string
			AceComm.callbacks:Fire(prefix, olddata..message, distribution, sender)
		end
	end
end






----------------------------------------
-- Embed CallbackHandler
----------------------------------------

if not AceComm.callbacks then
	AceComm.callbacks = CallbackHandler:New(AceComm,
						"_RegisterComm",
						"UnregisterComm",
						"UnregisterAllComm")
end

AceComm.callbacks.OnUsed = nil
AceComm.callbacks.OnUnused = nil

local function OnEvent(self, event, prefix, message, distribution, sender)
	if event == "CHAT_MSG_ADDON" then
		sender = Ambiguate(sender, "none")
		local control, rest = match(message, "^([\001-\009])(.*)")
		if control then
			if control==MSG_MULTI_FIRST then
				AceComm:OnReceiveMultipartFirst(prefix, rest, distribution, sender)
			elseif control==MSG_MULTI_NEXT then
				AceComm:OnReceiveMultipartNext(prefix, rest, distribution, sender)
			elseif control==MSG_MULTI_LAST then
				AceComm:OnReceiveMultipartLast(prefix, rest, distribution, sender)
			elseif control==MSG_ESCAPE then
				AceComm.callbacks:Fire(prefix, rest, distribution, sender)
			else
				-- unknown control character, ignore SILENTLY (dont warn unnecessarily about future extensions!)
			end
		else 
			-- single part: fire it off immediately and let CallbackHandler decide if it's registered or not
			AceComm.callbacks:Fire(prefix, message, distribution, sender)
		end
	else
		assert(false, "Received "..tostring(event).." event?!")
	end
end

AceComm.frame = AceComm.frame or CreateFrame("Frame", "AceComm30Frame")
AceComm.frame:SetScript("OnEvent", OnEvent)
AceComm.frame:UnregisterAllEvents()
AceComm.frame:RegisterEvent("CHAT_MSG_ADDON")


----------------------------------------
-- Base library stuff
----------------------------------------

local mixins = {
	"RegisterComm",
	"UnregisterComm",
	"UnregisterAllComm",
	"SendCommMessage",
}

-- Embeds AceComm-3.0 into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed AceComm-3.0 in
function AceComm:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

function AceComm:OnEmbedDisable(target)
	target:UnregisterAllComm()
end

-- Update embeds
for target, v in pairs(AceComm.embeds) do
	AceComm:Embed(target)
end
