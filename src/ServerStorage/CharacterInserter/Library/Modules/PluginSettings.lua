return {
	Version = 1.1,
	
	InsertWidget = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
		false,   -- Widget will be initially enabled
		true,  -- Don't override the previous enabled state
		200,    -- Default width of the floating window
		240,    -- Default height of the floating window
		200,    -- Minimum width of the floating window (optional)
		240     -- Minimum height of the floating window (optional)
	),
	
	HistoryWidget = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
		false,   -- Widget will be initially enabled
		true,  -- Don't override the previous enabled state
		400,    -- Default width of the floating window
		132,    -- Default height of the floating window
		400,    -- Minimum width of the floating window (optional)
		132     -- Minimum height of the floating window (optional)
	)
}