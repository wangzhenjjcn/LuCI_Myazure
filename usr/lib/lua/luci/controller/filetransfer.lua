module("luci.controller.filetransfer",package.seeall)
function index()
entry({"admin","system","filetransfer"},form("updownload"),_("FileTransfer"),89)
end
