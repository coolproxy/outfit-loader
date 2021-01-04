return function(plugin, title, info)
	local widget = plugin:CreateDockWidgetPluginGui(title, info)
	widget.Title = tostring(title)
	return widget
end