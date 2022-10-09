local ok, colorizer = pcall(require, "nvim-colorizer")
if not ok then
	return
end

colorizer.setup()
