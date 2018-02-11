------------------------
-- In The Name Of GoD --
--     Tabchi.lua     --
--    Bass By Naji    --
------------------------
DataBase = (loadfile "redis.lua")()
DataBase = DataBase.connect('127.0.0.1', 6379)
channel_id = -1001135894458
channel_user = "@DiamondKA"
local BOT = Tabchi-ID
function dl_cb(arg, data)
end
	function get_admin ()
	if DataBase:get('bibak'..BOT..'adminset') then
		return true
	else
    	print("\n\27[36m                      @DiamondKA \n >> Admin UserID :\n\27[31m                 ")
    	local admin=io.read()
		DataBase:del("bibak"..BOT.."admin")
    	DataBase:sadd("bibak"..BOT.."admin", admin)
		DataBase:set('bibak'..BOT..'adminset',true)
    	return print("\n\27[36m     ADMIN ID |\27[32m ".. admin .." \27[36m| شناسه ادمین")
	end
end
function get_bot (i, bibak)
	function bot_info (i, bibak)
		DataBase:set("bibak"..BOT.."id",bibak.id_)
		if bibak.first_name_ then
			DataBase:set("bibak"..BOT.."fname",bibak.first_name_)
		end
		if bibak.last_name_ then
			DataBase:set("bibak"..BOT.."lanme",bibak.last_name_)
		end
		DataBase:set("bibak"..BOT.."num",bibak.phone_number_)
		return bibak.id_
	end
	tdcli_function ({ID = "GetMe",}, bot_info, nil)
end
--[[function reload(chat_id,msg_id)
	loadfile("./bot-1.lua")()
	send(chat_id, msg_id, "<i>با موفقیت انجام شد.</i>")
end]]
function is_bibak(msg)
    local var = false
	local hash = 'bibak'..BOT..'admin'
	local user = msg.sender_user_id_
    local Bibak = DataBase:sismember(hash, user)
	if Bibak then
		var = true
	end
	return var
end
function writefile(filename, input)
	local file = io.open(filename, "w")
	file:write(input)
	file:flush()
	file:close()
	return true
end
function process_join(i, bibak)
	if bibak.code_ == 429 then
		local message = tostring(bibak.message_)
		local Time = message:match('%d+') + 85
		DataBase:setex("bibak"..BOT.."maxjoin", tonumber(Time), true)
	else
		DataBase:srem("bibak"..BOT.."goodlinks", i.link)
		DataBase:sadd("bibak"..BOT.."savedlinks", i.link)
	end
end
function process_link(i, bibak)
	if (bibak.is_group_ or bibak.is_supergroup_channel_) then
		DataBase:srem("bibak"..BOT.."waitelinks", i.link)
		DataBase:sadd("bibak"..BOT.."goodlinks", i.link)
	elseif bibak.code_ == 429 then
		local message = tostring(bibak.message_)
		local Time = message:match('%d+') + 85
		DataBase:setex("bibak"..BOT.."maxlink", tonumber(Time), true)
	else
		DataBase:srem("bibak"..BOT.."waitelinks", i.link)
	end
end
function find_link(text)
	if text:match("https://telegram.me/joinchat/%S+") or text:match("https://t.me/joinchat/%S+") or text:match("https://telegram.dog/joinchat/%S+") then
		local text = text:gsub("t.me", "telegram.me")
		local text = text:gsub("telegram.dog", "telegram.me")
		for link in text:gmatch("(https://telegram.me/joinchat/%S+)") do
			if not DataBase:sismember("bibak"..BOT.."alllinks", link) then
				DataBase:sadd("bibak"..BOT.."waitelinks", link)
				DataBase:sadd("bibak"..BOT.."alllinks", link)
			end
		end
	end
end
function add(id)
	local Id = tostring(id)
	if not DataBase:sismember("bibak"..BOT.."all", id) then
		if Id:match("^(%d+)$") then
			DataBase:sadd("bibak"..BOT.."users", id)
			DataBase:sadd("bibak"..BOT.."all", id)
		elseif Id:match("^-100") then
			DataBase:sadd("bibak"..BOT.."supergroups", id)
			DataBase:sadd("bibak"..BOT.."all", id)
		else
			DataBase:sadd("bibak"..BOT.."groups", id)
			DataBase:sadd("bibak"..BOT.."all", id)
		end
	end
	return true
end
function rem(id)
	local Id = tostring(id)
	if DataBase:sismember("bibak"..BOT.."all", id) then
		if Id:match("^(%d+)$") then
			DataBase:srem("bibak"..BOT.."users", id)
			DataBase:srem("bibak"..BOT.."all", id)
		elseif Id:match("^-100") then
			DataBase:srem("bibak"..BOT.."supergroups", id)
			DataBase:srem("bibak"..BOT.."all", id)
		else
			DataBase:srem("bibak"..BOT.."groups", id)
			DataBase:srem("bibak"..BOT.."all", id)
		end
	end
	return true
end
function send(chat_id, msg_id, text)
	 tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessageTypingAction",
      progress_ = 100
    }
  }, cb or dl_cb, cmd)
	tdcli_function ({
		ID = "SendMessage",
		chat_id_ = chat_id,
		reply_to_message_id_ = msg_id,
		disable_notification_ = 1,
		from_background_ = 1,
		reply_markup_ = nil,
		input_message_content_ = {
			ID = "InputMessageText",
			text_ = text,
			disable_web_page_preview_ = 1,
			clear_draft_ = 0,
			entities_ = {},
			parse_mode_ = {ID = "TextParseModeHTML"},
		},
	}, dl_cb, nil)
end
get_admin()
DataBase:set("bibak"..BOT.."start", true)
function OffExpire(msg, data)
	send(msg.chat_id_, msg.id_, "<i>⇜ زمان خاموشی به اتمام رسید و ربات روشن شد ! :)</i>")
end
function tdcli_update_callback(data)
	if data.ID == "UpdateNewMessage" then
		if DataBase:get("bibak"..BOT.."OFFTIME") then
			return
		end
		if not DataBase:get("bibak"..BOT.."maxlink") then
			if DataBase:scard("bibak"..BOT.."waitelinks") ~= 0 then
				local links = DataBase:smembers("bibak"..BOT.."waitelinks")
				for x,y in ipairs(links) do
					if x == 6 then DataBase:setex("bibak"..BOT.."maxlink", 70, true) return end
					tdcli_function({ID = "CheckChatInviteLink",invite_link_ = y},process_link, {link=y})
				end
			end
		end
		if not DataBase:get("bibak"..BOT.."maxjoin") then
			if DataBase:scard("bibak"..BOT.."goodlinks") ~= 0 then
				local links = DataBase:smembers("bibak"..BOT.."goodlinks")
				for x,y in ipairs(links) do
					tdcli_function({ID = "ImportChatInviteLink",invite_link_ = y},process_join, {link=y})
					if x == 2 then DataBase:setex("bibak"..BOT.."maxjoin", 70, true) return end
				end
			end
		end
		local msg = data.message_
		local bot_id = DataBase:get("bibak"..BOT.."id") or get_bot()
		if (msg.sender_user_id_ == 777000 or msg.sender_user_id_ == 178220800) then
			local c = (msg.content_.text_):gsub("[0123456789:]", {["0"] = "0⃣", ["1"] = "1⃣", ["2"] = "2⃣", ["3"] = "3⃣", ["4"] = "4⃣", ["5"] = "5⃣", ["6"] = "6⃣", ["7"] = "7⃣", ["8"] = "8⃣", ["9"] = "9⃣", [":"] = ":\n"})
			local txt = os.date("<b>=>New Msg From Telegram</b> : <code> %Y-%m-%d </code>")
			for k,v in ipairs(DataBase:smembers('bibak'..BOT..'admin')) do
				send(v, 0, txt.."\n\n"..c)
			end
		end
		if tostring(msg.chat_id_):match("^(%d+)") then
			if not DataBase:sismember("bibak"..BOT.."all", msg.chat_id_) then
				DataBase:sadd("bibak"..BOT.."users", msg.chat_id_)
				DataBase:sadd("bibak"..BOT.."all", msg.chat_id_)
			end
		end
		add(msg.chat_id_)
		if msg.date_ < os.time() - 150 then
			return false
		end
		if msg.content_.ID == "MessageText" then
    if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        chat_type = 'super'
        elseif id:match('^(%d+)') then
        chat_type = 'user'
        else
        chat_type = 'group'
        end
      end
			local text = msg.content_.text_
			local matches
			if DataBase:get("bibak"..BOT.."link") then
				find_link(text)
			end
	if text and text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
		text = text:lower()
		end
------TexTs-------
local Fwd1 = "⇜ پیام درحال ارسال به همه میباشد ..\n⇜ در هر <code>TIME</code> ثانیه پیام شما به <code>GPSF</code> گروه ارسال میشود .\n⇜ لطفا صبور باشید و تا پایان عملیات دستوری ارسال ننمایید !\n⇜ تا پایان این عملیات <code>ALL</code> ثانیه طول میکشد .\n▪️ ( <code>MIN</code> دقیقه )\n▪️ ( <code>H</code> ساعت )"
local Fwd3 = "⇜ پیام درحال ارسال به سوپرگروه ها میباشد ..\n⇜ در هر <code>TIME</code> ثانیه پیام شما به <code>GPSF</code> گروه ارسال میشود .\n⇜ لطفا صبور باشید و تا پایان عملیات دستوری ارسال ننمایید !\n⇜ تا پایان این عملیات <code>ALL</code> ثانیه طول میکشد .\n▪️ ( <code>MIN</code> دقیقه )\n▪️ ( <code>H</code> ساعت )"
local Fwd2 = "🔚 فروارد با موفقیت به اتمام رسید ."
local Done = "<i>⇜ انجام شد .</i>"
local Reload = "⇜ انجام شد .\n⇜ فایل <code>Tabchi.lua</code> با موفقیت بازنگری شد ."
local Help = "•⇩راهنمای دستورات⇩•\n➖➖➖➖➖➖\n• m USERID\n• افزودن ادمین\n••• به جای USERID آیدی عددی کاربر مورد نظر را قرار دهید .\n➖➖➖➖➖➖\n• md USERID\n• حذف ادمین\n••• به جای USERID آیدی عددی کاربر مورد نظر را قرار دهید .\n➖➖➖➖➖➖\n• f\n• فروارد پیام به همه (با ریپلی)\n➖➖➖➖➖➖\n• g Number\n• تنظیم تعداد گروه درهر فروارد\n••• به جای Number عدد مورد نظر خود را قرار دهید . (توجه کنید فقط عدد وارد کنید در غیر اینصورت در اجرای فرآیند به مشکل برمیخورید)\n➖➖➖➖➖➖\n• t Number\n• تنظیم زمان ارسال پیام به تعداد گروه مشخص شده ( ثانیه )\n••• به جای Number عدد مورد نظر خود را قرار دهید . (توجه کنید فقط عدد وارد کنید در غیر اینصورت در اجرای فرآیند به مشکل برمیخورید)\n➖➖➖➖➖➖\n• j o\n• فعال کردن عضویت در لینک ها (لینک ارسال نمایید ربات عضو میشود)\n➖➖➖➖➖➖\n• j d\n• غیر فعال کردن عضویت در لینک ها\n➖➖➖➖➖➖\n• fa\n• فعال کردن عضویت اجباری (ربات حتما در کانال ادمین باشد !)\n➖➖➖➖➖➖\n• fd\n• غیر فعال کردن عضویت اجباری\n➖➖➖➖➖➖\n• o\n• اطلاع از آنلاین بودن ربات\n➖➖➖➖➖➖\n• r\n• بازنگری فایل Tabchi.lua\n➖➖➖➖➖➖\n• e TEXT\n• تکرار کردن متن\n••• به جای TEXT متن مورد نظر را قرار دهید .\n➖➖➖➖➖➖\n• a \n• دریافت آمار ربات\n➖➖➖➖➖➖\n• fg Type\n• تنظیم حالت ارسال ( ارسال به همه یا ارسال به سوپرگروه )\n••• به جای Type ; برای تنظیم به ارسال به همه از a و برای تنظیم ارسال به سوپرگروه از s استفاده نمایید .\n➖➖➖➖➖➖\n▪️ از انتشار این سورس به هیچ وجه راضی نمیباشیم ...\n▪️▪️ نوشته شده توسط :\n▪️▪️ @I_Abbas\n▪️▪️▪️ کانال :\n▪️▪️▪️ @DiamondKA"
local stats = "▪️ آمار\n⇜ گروه ها : <code>GP</code>\n⇜ سوپر گروه ها : <code>SU</code>\n⇜ پیوی ها : <code>USR</code>\n▪️ وضعیت ارسال ⇜ <code>[ FWD ]</code> \n⇜ در هر <code>TIME</code> ثانیه پیام شما به <code>FUCK</code> گروه ارسال میشود .\n▪️ عضویت خودکار [ <code>JOIN</code> ] میباشد .\n ⇜ لینک های عضو شده : <code>LINK</code> لینک\n⇜ لینک های در انتظار عضویت : <code>GL</code> لینک "
local off = "⇜ انجام شد .\n⇜ ربات به مدت <code>TIME</code> ثانیه خاموش شد !"
local forcejointxt = {'عزیزم اول تو کانالم عضو شو بعد بیا بحرفیم😃❤️\nآیدی کانالم :\n'..channel_user,'عه هنوز تو کانالم نیستی🙁\nاول بیا کانالم بعد بیا چت کنیم😍❤️\nآیدی کانالم :\n'..channel_user,'عشقم اول بیا کانالم بعد بیا پی وی حرف بزنیم☺️\nاومدی بگو 😃❤️\nآیدی کانالم :\n'..channel_user}
local forcejoin = forcejointxt[math.random(#forcejointxt)]
------------------
		if chat_type == 'user' then
local bibak = DataBase:get('bibak'..BOT..'forcejoin')
if bibak then
if text:match('(.*)') then
function checmember_cb(ex,res)
      if res.ID == "ChatMember" and res.status_ and res.status_.ID and res.status_.ID ~= "ChatMemberStatusMember" and res.status_.ID ~= "ChatMemberStatusEditor" and res.status_.ID ~= "ChatMemberStatusCreator" then
      return send(msg.chat_id_, msg.id_,forcejoin)
      else
return 
end
end
end
else
if text:match('(.*)') then
return
end
end
tdcli_function ({ID = "GetChatMember",chat_id_ = channel_id, user_id_ = msg.sender_user_id_}, checmember_cb, nil)
    end	
			if is_bibak(msg) then
				find_link(text)
								if text:match("^(bo) (%d+)$") then
					local matches = tonumber(text:match("%d+"))
					DataBase:setex('bibak'..BOT..'OFFTIME', matches, true)
					tdcli_function ({
					ID = "SetAlarm",
					seconds_ = matches
					}, OffExpire, msg)
					local text = off:gsub("TIME",matches)
					return send(msg.chat_id_, msg.id_, text)
				elseif text:match("^(modset) (%d+)$") then
					local matches = text:match("%d+")
					if DataBase:sismember('bibak'..BOT..'admin', matches) then
						return send(msg.chat_id_, msg.id_, "<i>کاربر مورد نظر در حال حاضر مدیر است.</i>")
					elseif DataBase:sismember('bibak'..BOT..'mod', msg.sender_user_id_) then
						return send(msg.chat_id_, msg.id_, "شما دسترسی ندارید.")
					else
						DataBase:sadd('bibak'..BOT..'admin', matches)
						DataBase:sadd('bibak'..BOT..'mod', matches)
						return send(msg.chat_id_, msg.id_, Done)
					end
				elseif text:match("^(m) (%d+)$") then
					local matches = text:match("%d+")
					if DataBase:sismember('bibak'..BOT..'admin', matches) then
						return send(msg.chat_id_, msg.id_, "<i>کاربر مورد نظر در حال حاضر مدیر است.</i>")
					elseif DataBase:sismember('bibak'..BOT..'mod', msg.sender_user_id_) then
						return send(msg.chat_id_, msg.id_, "شما دسترسی ندارید.")
					else
						DataBase:sadd('bibak'..BOT..'admin', matches)
						DataBase:sadd('bibak'..BOT..'mod', matches)
						return send(msg.chat_id_, msg.id_, Done)
					end
				elseif text:match("^(md) (%d+)$") then
					local matches = text:match("%d+")
					if DataBase:sismember('bibak'..BOT..'mod', msg.sender_user_id_) then
						if tonumber(matches) == msg.sender_user_id_ then
								DataBase:srem('bibak'..BOT..'admin', msg.sender_user_id_)
								DataBase:srem('bibak'..BOT..'mod', msg.sender_user_id_)
							return send(msg.chat_id_, msg.id_, "شما دیگر مدیر نیستید.")
						end
						return send(msg.chat_id_, msg.id_, "شما دسترسی ندارید.")
					end
					if DataBase:sismember('bibak'..BOT..'admin', matches) then
						if  DataBase:sismember('bibak'..BOT..'admin'..msg.sender_user_id_ ,matches) then
							return send(msg.chat_id_, msg.id_, "شما نمی توانید مدیری که به شما مقام داده را عزل کنید.")
						end
						DataBase:srem('bibak'..BOT..'admin', matches)
						DataBase:srem('bibak'..BOT..'mod', matches)
						return send(msg.chat_id_, msg.id_, Done)
					end
					return send(msg.chat_id_, msg.id_, "کاربر مورد نظر مدیر نمی باشد.")
						elseif text:match("^(r)$") then
       dofile('./Tabchi.lua') 
 return send(msg.chat_id_, msg.id_, Reload)
 elseif text:match("^(h)$") then
 return send(msg.chat_id_, msg.id_, Help)
 elseif text:match("^(fa)$") then
 DataBase:set("bibak"..BOT.."forcejoin", true)
 return send(msg.chat_id_, msg.id_, Done)
 elseif text:match("^(fd)$") then
 DataBase:del('bibak'..BOT..'forcejoin')
 return send(msg.chat_id_, msg.id_, Done)
 			elseif text:match("^(test)$") then
  local timee = DataBase:get('bibak'..BOT..'timef') or 30
				local gpsf = DataBase:get('bibak'..BOT..'gpsf') or 6
     			local all = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
				local bibak = "bibak"..BOT.."supergroups"
				local alltimee = (all / gpsf) * timee
				local timemmin = ((all / gpsf) * timee) / 60 
 return send(msg.chat_id_, msg.id_, timemmin)
 elseif text:match("^(e) (.*)") then
					local matches = text:match("^e (.*)")
					return send(msg.chat_id_, msg.id_, matches)
				elseif (text:match("^(o)$") and not msg.forward_info_)then
					return tdcli_function({
						ID = "ForwardMessages",
						chat_id_ = msg.chat_id_,
						from_chat_id_ = msg.chat_id_,
						message_ids_ = {[0] = msg.id_},
						disable_notification_ = 0,
						from_background_ = 1
					}, dl_cb, nil)
					elseif text:match("^(rs)$")then
					local list = {DataBase:smembers("bibak"..BOT.."supergroups"),DataBase:smembers("bibak"..BOT.."groups"),DataBase:smembers("bibak"..BOT.."users")}
				tdcli_function({
						ID = "SearchContacts",
						query_ = nil,
						limit_ = 999999999
					}, function (i, bibak)
						DataBase:set("bibak"..BOT.."contacts", bibak.total_count_)
					end, nil)
					for i, v in ipairs(list) do
							for a, b in ipairs(v) do 
								tdcli_function ({
									ID = "GetChatMember",
									chat_id_ = b,
									user_id_ = bot_id
								}, function (i,bibak)
									if  bibak.ID == "Error" then rem(i.id) 
									end
								end, {id=b})
							end
					end
					 send(msg.chat_id_, msg.id_, Done)
					elseif text:match("^(sh)$") then
					      get_bot()
					local fname = DataBase:get("bibak"..BOT.."fname")
					local lnasme = DataBase:get("bibak"..BOT.."lname") or ""
					local num = DataBase:get("bibak"..BOT.."num")
					tdcli_function ({
						ID = "SendMessage",
						chat_id_ = msg.chat_id_,
						reply_to_message_id_ = msg.id_,
						disable_notification_ = 1,
						from_background_ = 1,
						reply_markup_ = nil,
						input_message_content_ = {
							ID = "InputMessageContact",
							contact_ = {
								ID = "Contact",
								phone_number_ = num,
								first_name_ = fname,
								last_name_ = lname,
								user_id_ = bot_id
							},
						},
					}, dl_cb, nil)
						elseif text:match("^(a)$") then
					if DataBase:get("bibak"..BOT.."fwd") then
					local fwd = "ارسال به همه"
					local links = tostring(DataBase:scard("bibak"..BOT.."savedlinks"))
					local glinks = tostring(DataBase:scard("bibak"..BOT.."goodlinks"))
					local gps = tostring(DataBase:scard("bibak"..BOT.."groups"))
					local sgps = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
					local usrs = tostring(DataBase:scard("bibak"..BOT.."users"))
					local timee = DataBase:get('bibak'..BOT..'timef') or 30
			    	local gpsf = DataBase:get('bibak'..BOT..'gpsf') or 6
					local offjoin = DataBase:get("bibak"..BOT.."offjoin") and "غیر فعال" or "فعال"
					local text = stats:gsub("GP",gps):gsub("SU",sgps):gsub("USR",usrs):gsub("TIME",timee):gsub("FUCK",gpsf):gsub("JOIN",offjoin):gsub("FWD",fwd):gsub("LINK",links):gsub("GL",glinks)
					return send(msg.chat_id_, msg.id_, text)
					else
					local gps = tostring(DataBase:scard("bibak"..BOT.."groups"))
					local fwd = "ارسال به سوپرگروه"
					local links = tostring(DataBase:scard("bibak"..BOT.."savedlinks"))
					local glinks = tostring(DataBase:scard("bibak"..BOT.."goodlinks"))
				    local sgps = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
					local usrs = tostring(DataBase:scard("bibak"..BOT.."users"))
					local timee = DataBase:get('bibak'..BOT..'timef') or 30
			    	local gpsf = DataBase:get('bibak'..BOT..'gpsf') or 6
					local offjoin = DataBase:get("bibak"..BOT.."offjoin") and "غیر فعال" or "فعال"
					local text = stats:gsub("GP",gps):gsub("SU",sgps):gsub("USR",usrs):gsub("TIME",timee):gsub("FUCK",gpsf):gsub("JOIN",offjoin):gsub("FWD",fwd):gsub("LINK",links):gsub("GL",glinks)
					return send(msg.chat_id_, msg.id_, text)
										end
						elseif text:match("^(j o)$") then
						DataBase:del("bibak"..BOT.."maxjoin")
						DataBase:del("bibak"..BOT.."offjoin")
						DataBase:set("bibak"..BOT.."link", true)
						return send(msg.chat_id_, msg.id_, Done)
						elseif text:match("^(j d)$") then
						DataBase:set("bibak"..BOT.."maxjoin", true)
						DataBase:set("bibak"..BOT.."offjoin", true)
						DataBase:del("bibak"..BOT.."link")
						return send(msg.chat_id_, msg.id_, Done)
						elseif text:match("^(t) (%d+)$") then
					local matches = text:match("%d+")
					DataBase:set('bibak'..BOT..'timef',matches)
					return send(msg.chat_id_, msg.id_, Done)
					elseif text:match("^(g) (%d+)$") then
					local matches = text:match("%d+")
					DataBase:set('bibak'..BOT..'gpsf',matches)
					return send(msg.chat_id_, msg.id_, Done)
					elseif text:match("^(fg) (.*)") then
					local bg = text:match("^fg (.*)")
					if bg:match("^(a)") then
					DataBase:set("bibak"..BOT.."fwd", true)					 
					 local text = "⇜ انجام شد .\n⇜ واضعیت ارسال پیام به [ <code>ارسال به همه</code> ] تغییر کرد ."
					 send(msg.chat_id_, msg.id_, text)
					 elseif bg:match("^(s)") then
                     DataBase:del("bibak"..BOT.."fwd")
					  local text = "⇜ انجام شد .\n⇜ واضعیت ارسال پیام به [ <code>ارسال به سوپرگروه</code> ] تغییر کرد ."
					 send(msg.chat_id_, msg.id_, text)
					 end 
				elseif (text:match("^(f)$") and msg.reply_to_message_id_ ~= 0) then
				 if DataBase:get("bibak"..BOT.."fwd") then  
				local timee = DataBase:get('bibak'..BOT..'timef') or 30
				local gpsf = DataBase:get('bibak'..BOT..'gpsf') or 6
     			local all = tostring(DataBase:scard("bibak"..BOT.."all"))
				local bibak = "bibak"..BOT.."all"
				local alltimee = (all / gpsf) * timee
				local timemmin = ((all / gpsf) * timee) / 60 
				local timeh = ((all / gpsf) * timee) / 3600 
				local text = Fwd1:gsub("TIME",timee):gsub("GPSF",gpsf):gsub("ALL",alltimee):gsub("MIN",timemmin):gsub("H",timeh)
				send(msg.chat_id_, msg.id_, text)
				local list = DataBase:smembers(bibak)
				local id = msg.reply_to_message_id_
						for i, v in pairs(list) do
							tdcli_function({
								ID = "ForwardMessages",
								chat_id_ = v,
								from_chat_id_ = msg.chat_id_,
								message_ids_ = {[0] = id},
								disable_notification_ = 1,
								from_background_ = 1
							}, dl_cb, nil)
							if i % gpsf == 0 then
								os.execute("sleep "..timee.."")
							end
							end
					return send(msg.chat_id_, msg.id_, Fwd2)
				else
						local timee = DataBase:get('bibak'..BOT..'timef') or 30
				local gpsf = DataBase:get('bibak'..BOT..'gpsf') or 6
     			local all = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
				local bibak = "bibak"..BOT.."supergroups"
				local alltimee = (all / gpsf) * timee
				local timemmin = ((all / gpsf) * timee) / 60 
				local timeh = ((all / gpsf) * timee) / 3600 
				local text = Fwd1:gsub("TIME",timee):gsub("GPSF",gpsf):gsub("ALL",alltimee):gsub("MIN",timemmin):gsub("H",timeh)
				send(msg.chat_id_, msg.id_, text)
				local list = DataBase:smembers(bibak)
				local id = msg.reply_to_message_id_
						for i, v in pairs(list) do
							tdcli_function({
								ID = "ForwardMessages",
								chat_id_ = v,
								from_chat_id_ = msg.chat_id_,
								message_ids_ = {[0] = id},
								disable_notification_ = 1,
								from_background_ = 1
							}, dl_cb, nil)
							if i % gpsf == 0 then
								os.execute("sleep "..timee.."")
							end
							end
					return send(msg.chat_id_, msg.id_, Fwd2)
					end
				end
					 end 
		elseif msg.content_.ID == "MessageChatDeleteMember" and msg.content_.id_ == bot_id then
			return rem(msg.chat_id_)
		elseif (msg.content_.caption_ and DataBase:get("bibak"..BOT.."link"))then
			find_link(msg.content_.caption_)
		end
		if DataBase:get("bibak"..BOT.."markread") then
			tdcli_function ({
				ID = "ViewMessages",
				chat_id_ = msg.chat_id_,
				message_ids_ = {[0] = msg.id_} 
			}, dl_cb, nil)
		end
	elseif data.ID == "UpdateOption" and data.name_ == "my_id" then
		tdcli_function ({
			ID = "GetChats",
			offset_order_ = 9223372036854775807,
			offset_chat_id_ = 0,
			limit_ = 1000
		}, dl_cb, nil)
	end
end
--------------------
-- End Tabchi.lua --
--    By Bibak    --
--------------------
