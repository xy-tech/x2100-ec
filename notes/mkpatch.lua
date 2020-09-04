-- usage: binutils/bin/cr16-unknown-elf-objdump -wD fastcharge2.oo | lua mkpatch.lua
while true do
	line = io.read("*line")
	if not line then break end
	addr,bytes = line:match("   2(....):[%s]+([^\t]+)")
	if addr then
		print("0x"..addr.." "..bytes:gsub(" ",""))
	end
end