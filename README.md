# codecompanion-titlestring.nvim

Show [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) agent status in your **terminal title bar** via `vim.o.titlestring`.

Requires a terminal that supports dynamic window titles (Windows Terminal, Alacritty, iTerm2, most modern terminals).

## What it does

The plugin updates the terminal title with an icon that reflects the current agent state.

| State | Title prefix | Trigger |
| --- | --- | --- |
| Idle | `󰺴` | Default |
| Working | `󰚩` / `󱚝` (animated) | Chat submitted, non-chat requests |
| Compacting | spinner + `󱜙` | `CodeCompanionChatCompacting` |
| Approval pending | `󰚩 󰭺` | Tool / CLI approval requested |
| Tool question | `󰚩 󱜸` | Agent asks a question |

Example titles:

```
󰺴 my-project          ← idle
󰚩 my-project          ← agent is working
󰚩 󰭺 my-project        ← waiting for your approval
```

## Requirements

- Neovim 0.10+
- [olimorris/codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)
- Ideally, a Nerd Font in your terminal (for icons)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim), register the plugin as a CodeCompanion extension:

```lua
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "KissYagni/codecompanion-titlestring.nvim",
  },
  opts = {
    extensions = {
      titlestring = {
        enabled = true,
        -- only specify options you want to override;
        -- defaults are shown below
        opts = {
          icons = {
            -- Shown when the agent is idle (default: "")
            idle = "",
            -- Can be single icone or array. In case of arrayn, alternated while the agent is working 
            thinking = { "󰚩", "󱚝" },
            -- Waiting for tool or CLI approval 
            approval = "󰚩 󰭺 ",
            -- Agent asked a question 
            question = "󰚩 󱜸 ",
            -- Can be single icone or array. In case of arrayn, alternated while the agent is compactng 
            compacting = "󱜙 ",
          },
        },
      },
    },
  },
}
```

LazyVim merges nested `opts` automatically — override individual fields without repeating the rest.

## License

MIT
