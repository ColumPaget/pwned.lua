require("stream")
require("dataparser")
require("strutil")
require("process")
require("terminal")
require("hash")
require("net")

VERSION="1.1"

function ReadBreach(I)
local breach={}
local C, classes

breach.classes=""
breach.date=I:value("BreachDate")
breach.name=I:value("Name")
breach.count=tonumber(I:value("PwnCount"))
breach.fake=false
breach.verified=false
breach.sensitive=false
breach.identity=false 
breach.bank=false 
breach.creditcard=false 
breach.age=false 
breach.ipaddress=false 
breach.phone=false 
breach.location=false 
breach.gender=false 
breach.race=false 
breach.habits=false 
breach.sexual=false 
breach.messages=false 
breach.passwords=false 
breach.description=I:value("Description")

if I:value("IsFabricated") == "true" then breach.fake=true end 
if I:value("IsVerified") == "true" then breach.verified=true end 
if I:value("IsSensitive") == "true" then breach.sensitive=true end

classes=I:open("DataClasses")
if classes ~= nil
then
C=classes:next()
while C ~=nil
do
breach.classes=breach.classes..C:value()..", "

if C:value() == "Email addresses" then breach.identity=true end
if C:value() == "Recovery email address" then breach.identity=true end
if C:value() == "Names" then breach.identity=true end
if C:value() == "Family members' names" then breach.identity=true end
if C:value() == "Instant messenger identities" then breach.identity=true end
if C:value() == "Government issued IDs" then breach.identity=true end
if C:value() == "Passport numbers" then breach.identity=true end
if C:value() == "Social media profiles" then breach.identity=true end
if C:value() == "Bank account numbers" then breach.bank=true end
if C:value() == "Banking PINs" then breach.bank=true end
if C:value() == "Dates of birth" then breach.age=true end
if C:value() == "Ages" then breach.age=true end
if C:value() == "Age groups" then breach.age=true end
if C:value() == "IP addresses" then breach.ipaddress=true end
if C:value() == "Phone numbers" then breach.phone=true end
if C:value() == "Geographic location" then breach.location=true end
if C:value() == "Physical addresses" then breach.location=true end
if C:value() == "Time zones" then breach.location=true end
if C:value() == "Genders" then breach.gender=true end
if C:value() == "Credit cards" then breach.creditcard=true end
if C:value() == "Credit card CVV" then breach.creditcard=true end
if C:value() == "Partial Credit card data" then breach.creditcard=true end
if C:value() == "Ethnicities" then breach.race=true end
if C:value() == "Races" then breach.race=true end
if C:value() == "Smoking habits" then breach.habits=true end
if C:value() == "Drinking habits" then breach.habits=true end
if C:value() == "Eating habits" then breach.habits=true end
if C:value() == "Drug habits" then breach.habits=true end
if C:value() == "Sexual fetishes" then breach.sexual=true end
if C:value() == "Sexual orientation" then breach.sexual=true end
if C:value() == "Email messages" then breach.messages=true end
if C:value() == "SMS messages" then breach.messages=true end
if C:value() == "Private messages" then breach.messages=true end
if C:value() == "Chat logs" then breach.messages=true end
if C:value() == "Passwords" then breach.passwords=true end
if C:value() == "Historical passwords" then breach.passwords=true end
if C:value() == "Auth tokens" then breach.passwords=true end


-- print("class: ".. C:value())
-- :["Auth tokens","Dates of birth","Email addresses","Genders","Names","Phone numbers","Usernames"]
C=classes:next()
end
end

return breach
end



function BreachSortName(i1, i2)
return string.lower(i1.name) < string.lower(i2.name)
end

function BreachSortSize(i1, i2)
return i1.count < i2.count
end

function BreachSortDate(i1, i2)
return i1.date < i2.date
end



function LoadBreaches(url, settings)
local S, P, I, json
local list={}

if (settings.debug) then print("URL: "..url) end
S=stream.STREAM(url)
if S:getvalue("HTTP:ResponseCode")=="404" then return nil end
json=S:readdoc()
if settings.debug == true then print(json) end
P=dataparser.PARSER("json",json);

I=P:open("/");
while I:next()
	do
	breach=ReadBreach(I)
	if breach ~= nil 
	then 
		if strutil.strlen(settings.date) > 0
		then
			if strutil.pmatch(settings.date, breach.date) > 0 then table.insert(list, breach) end
		else
			table.insert(list, breach) 
		end
	end
end

if settings.sort == "name" then 
	table.sort(list, BreachSortName) 
elseif settings.sort == "size" then 
	table.sort(list, BreachSortSize) 
elseif settings.sort == "date" then 
	table.sort(list, BreachSortDate) 
end

return list
end


function DisplayBreaches(url, settings)
local list
local tempstr=""
local flags, qtyStr
local bcount=0

	list=LoadBreaches(url, settings)
	if list == nil then return false end


	for i=1,#list,1
	do
		breach=list[i]
		flags=""
		if breach.fake == true 
		then 
			flags="F" 
		else
			if breach.verified == true then flags="~gV~0" end
		end

		if breach.sensitive == true then flags=flags.."~rX~0" end
		if breach.identity == true then flags=flags.."~mi~0" end
		if breach.bank == true then flags=flags.."~rB~0" end
		if breach.creditcard == true then flags=flags.."~rC~0" end
		if breach.age == true then flags=flags.."~ca~0" end
		if breach.ipaddress == true then flags=flags.."~gI~0" end
		if breach.gender == true then flags=flags.."~bs~0" end
		if breach.sexual == true then flags=flags.."~rx~0" end
		if breach.habits == true then flags=flags.."~mh~0" end
		if breach.messages == true then flags=flags.."~e~yM~0" end
		if breach.location == true then flags=flags.."~e~cG~0" end
		if breach.phone == true then flags=flags.."~bP~0" end
		if breach.passwords == true then flags=flags.."~rA~0" end

		while terminal.strlen(flags) < 12 do flags=flags.." " end

		if settings.full_qty==true
		then
			qtyStr=string.format("%d",breach.count);
		else
			qtyStr=strutil.toMetric(breach.count);
		end
	
		if settings.details == true
		then
			tempstr=string.format("~e~g%s~0  ~e~m%s~0  ~e~b%s~0    %s\n%s\n\n", breach.date, breach.name, qtyStr, breach.classes, breach.description)
		elseif settings.only_qty==true 
		then  
			--do nothing
		else
			tempstr=string.format("%s  %s  ~m%s~0  ~e~b%s~0\n", breach.date, flags, breach.name, qtyStr)
		end


		Out:puts(tempstr)
		bcount=bcount+1
	end

	if settings.details == false and settings.only_qty == false
	then
	Out:puts("Key: ~gV~0=Verified F=Fake ~rX~0=Sensitive ~rA~0=Authentication/Passwords ~rB~0=Bank details ~rC~0=Credit Card Info ~ca~0=Age info ~gI~0=IP Addresss ~bs~0=sex/gender ~rx~0=sexual info ~mh~0=habits (drink,drugs,smoking,eating) ~mi~0=Identity Info ~e~yM~0=messages ~e~cG~0=Geographic location ~bP~0=Phone \n");
	end

	if settings.only_qty==true 
	then 
		print(string.format("%d",bcount))
	elseif bcount==0 
	then
		if settings.only_qty == true 
		then 
			print("0")
		else	
		Out:puts("~gNo breaches found~0\n") 
		end	
	end

	return bcount
end


function ListBreaches(settings)
return(DisplayBreaches("https://haveibeenpwned.com/api/v2/breaches", settings))
end

function CheckAccount(account, settings)
return(DisplayBreaches("https://haveibeenpwned.com/api/v2/breachedaccount/" .. strutil.httpQuote(account), settings))
end


function CheckPassword(passwd)
local S, sha1, Toks, url
local line, phash, pcount


sha1=string.upper(hash.hashstr(passwd, "sha1", "HEX"))

url="https://api.pwnedpasswords.com/range/".. string.sub(sha1,1,5)
if (settings.debug) then print("URL: "..url) end

S=stream.STREAM(url)
line=S:readln()
while line ~= nil
do
	line=strutil.stripTrailingWhitespace(line)
	if strutil.strlen(line) > 0
	then
		Toks=strutil.TOKENIZER(line, ":")
		phash=string.sub(sha1,1,5) .. Toks:next();
		pcount=Toks:next();
	
		if phash == sha1 
		then 
			if settings.only_qty==true 
			then
					print(string.format("%d", pcount))
			else 
					Out:puts("~rFOUND:~0  "..pcount.." uses of this password\n") 
			end
			return tonumber(pcount)
		end
	end
	line=S:readln()
end

if settings.only_qty==true 
then
print("0")
else
Out:puts("~gpassword not found in breach list~0\n") 
end

return 0
end



function CheckPastes(account)
local url, S, P, I, json
local tempstr=""
local pcount=0

url="https://haveibeenpwned.com/api/v2/pasteaccount/".. strutil.httpQuote(account)
if (settings.debug) then print("URL: "..url) end
S=stream.STREAM(url)
if S:getvalue("HTTP:ResponseCode")=="200"
then
	json=S:readdoc()
	print(json)
	P=dataparser.PARSER("json",json);
	
	I=P:open("/");
	while I:next()
	do
		date=I:value("Date");
		if strutil.strlen(date) ==0 then date="unknown"; end
		tempstr=tempstr..string.format("%s %s %s %d\n", date, I:value("Source"), I:value("ID"), I:value("EmailCount"))
		pcount=pcount+1
	end
end

if settings.only_qty==true 
then
	print(string.format("%d",pcount))
elseif pcount == 0
then
	Out:puts("~gNo pastes found!~0\n")
else
	Out:puts(tempstr)
end

return pcount
end


function ParseCommandLine(arg)
local i
local settings={}
local query=""
local qarg=""

settings.details=false
settings.debug=false
settings.only_qty=false
settings.proxy="" 
settings.sort="" 
settings.date="" 
settings.userAgent="pwned.lua-"..VERSION;

-- simply incrementing i when we parse an argument doesnt' seem to work
-- so we need to blank out arguments when we've used them with
-- 'arg[i]=""'

for i=1,#arg,1
do
	if arg[i]=="-s" 
	then
		settings.sort=arg[i+1]
		arg[i+1]=""
	elseif arg[i]=="-d" 
	then
		settings.date=arg[i+1]
		arg[i+1]=""
	elseif arg[i]=="-u" 
	then
		settings.userAgent=arg[i+1]
		arg[i+1]=""
	elseif arg[i]=="-p" 
	then
		settings.proxy=arg[i+1]
		arg[i+1]=""
	elseif arg[i]=="-n" then settings.full_qty=true
	elseif arg[i]=="-q" then settings.only_qty=true
	elseif arg[i]=="-D" then settings.debug=true
	elseif arg[i]=="-v" then settings.details=true
	elseif strutil.strlen(arg[i]) > 0 then
		if query == "" then query=arg[i]
		else qarg=arg[i]
		end
	end
end

return query, qarg, settings
end


function DisplayUsage()

print()
print("pwned.lua version: "..VERSION)
print()
print("pwned.lua breaches [options]                   - list all breaches")
print("pwned.lua account <account name> [options]     - list breaches for named account")
print("pwned.lua password <password> [options]        - check number of occurances of <password> in breaches")
print("pwned.lua pastes <account name> [options]      - list sites where account details have been pasted")
print()
print("most queries will return the number of matching breaches found, or in the case of 'password' queries, the number of accounts using that password. Unfortunately exit codes cannot go above 127, thus for scripts it is better to use the -q option.")
print()
print("'password' queries never send you password. Instead they generate a sha1 has of the password, and send the first 5 bytes of it. haveibeenpwned.com responds with information on all the sha1 hashes of passwords that start with the same 5 bytes. From these we pick out the one that matches our sha1 hash, if any do, thus identifying our password amoung the data. Thus passwords are never disclosed in using the service.")
print()
print("options: ")
print("  -s <sort type>    - sort breaches by 'date', 'size' or 'name'")
print("  -d <date>         - only show breaches matching fnmatch-style pattern <date>. e.g. -d 2017-*")
print("  -v                - show more detail")
print("  -q                - output just a number representing the number of accounts/passwords found")
print("  -n                - format qty as full number rather than metric (i.e. 1200 rather than 1.2k)")
print("  -u <user-agent>   - set user-agent string for https communications")
print("  -p <proxy>        - use proxy. e.g. socks4:127.0.0.1:1080, socks5:192.168.1.1:1080, sshtunnel:user:password@ssh-server, https:user@proxy.com:1080")
print("  -D                - enable debug output")
end


Out=terminal.TERM();
query,qarg,settings=ParseCommandLine(arg)

process.lu_set("HTTP:UserAgent", settings.userAgent)
if settings.debug == true then process.lu_set("HTTP:Debug","y") end
if settings.proxy ~= "" then net.setProxy(settings.proxy) end

if query=="account" then
	count=CheckAccount(qarg, settings)
elseif query=="passwd" or query=="password" then
	count=CheckPassword(qarg)
elseif query=="pastes" then
	count=CheckPastes(qarg)
elseif query=="breaches" then
 count=ListBreaches(settings)
else
	DisplayUsage()
end

Out:reset()
os.exit(count)
