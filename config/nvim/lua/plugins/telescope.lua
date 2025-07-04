return {
  -- Fuzzy finder (files, lsp, etc)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      
      telescope.setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = " ",
          path_display = { "truncate" },
          file_ignore_patterns = {
            "%.git/",
            "%.DS_Store",
            "node_modules/",
            "%.lock",
            "package-lock.json",
          },
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-l>"] = actions.complete_tag,
              ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
            },
            n = {
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["H"] = actions.move_to_top,
              ["M"] = actions.move_to_middle,
              ["L"] = actions.move_to_bottom,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["gg"] = actions.move_to_top,
              ["G"] = actions.move_to_bottom,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["?"] = actions.which_key,
            },
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            previewer = false,
            hidden = true,
          },
          live_grep = {
            theme = "dropdown",
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
            initial_mode = "normal",
          },
          help_tags = {
            theme = "ivy",
          },
          colorscheme = {
            enable_preview = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      -- Load extensions
      pcall(require('telescope').load_extension, 'fzf')
      
      -- Custom functions
      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf = require('telescope.config').values
      local previewers = require('telescope.previewers')
      
      -- Custom git diff files picker
      local function git_diff_files(opts)
        opts = opts or {}
        
        -- Get files with differences
        local cmd = { 'git', 'diff', '--name-only', 'HEAD' }
        local handle = io.popen(table.concat(cmd, ' '))
        local result = handle:read('*a')
        handle:close()
        
        if result == '' then
          vim.notify('No files with differences found', vim.log.levels.INFO)
          return
        end
        
        -- Parse files
        local files = {}
        for file in result:gmatch('[^\r\n]+') do
          table.insert(files, file)
        end
        
        if #files == 0 then
          vim.notify('No files with differences found', vim.log.levels.INFO)
          return
        end
        
        pickers.new(opts, {
          prompt_title = 'Git Diff Files',
          finder = finders.new_table {
            results = files,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry,
                ordinal = entry,
                path = entry,
              }
            end,
          },
          sorter = conf.generic_sorter(opts),
          previewer = previewers.new_termopen_previewer {
            get_command = function(entry)
              return { 'git', 'diff', 'HEAD', '--', entry.path }
            end,
          },
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = require('telescope.actions.state').get_selected_entry()
              if selection then
                vim.cmd('edit ' .. selection.path)
              end
            end)
            
            -- Add mapping to show full diff in a new tab
            map('i', '<C-d>', function()
              local selection = require('telescope.actions.state').get_selected_entry()
              if selection then
                actions.close(prompt_bufnr)
                vim.cmd('tabnew')
                vim.cmd('terminal git diff HEAD -- ' .. selection.path)
                vim.cmd('startinsert')
              end
            end)
            
            return true
          end,
        }):find()
      end
      
      -- Key mappings
      local builtin = require('telescope.builtin')
      local keymap = vim.keymap.set
      
      -- File and project navigation
      keymap('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      keymap('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
      keymap('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
      keymap('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
      keymap('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
      keymap('n', '<leader>fw', builtin.grep_string, { desc = 'Grep word under cursor' })
      keymap('n', '<leader>fc', builtin.commands, { desc = 'Commands' })
      keymap('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })
      
      -- Git integration
      keymap('n', '<leader>gf', builtin.git_files, { desc = 'Git files' })
      keymap('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
      keymap('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
      keymap('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })
      keymap('n', '<leader>gd', git_diff_files, { desc = 'Git diff files' })
      
      -- LSP integration
      keymap('n', '<leader>lr', builtin.lsp_references, { desc = 'LSP references' })
      keymap('n', '<leader>ld', builtin.lsp_definitions, { desc = 'LSP definitions' })
      keymap('n', '<leader>li', builtin.lsp_implementations, { desc = 'LSP implementations' })
      keymap('n', '<leader>ls', builtin.lsp_document_symbols, { desc = 'Document symbols' })
      keymap('n', '<leader>lw', builtin.lsp_workspace_symbols, { desc = 'Workspace symbols' })
      keymap('n', '<leader>le', builtin.diagnostics, { desc = 'Diagnostics' })
      
      -- Search and navigation
      keymap('n', '<leader>s/', builtin.current_buffer_fuzzy_find, { desc = 'Search in buffer' })
      keymap('n', '<leader>sm', builtin.marks, { desc = 'Marks' })
      keymap('n', '<leader>sr', builtin.registers, { desc = 'Registers' })
      keymap('n', '<leader>sj', builtin.jumplist, { desc = 'Jump list' })
      keymap('n', '<leader>sh', builtin.search_history, { desc = 'Search history' })
      keymap('n', '<leader>sc', builtin.command_history, { desc = 'Command history' })
      keymap('n', '<leader>ss', builtin.spell_suggest, { desc = 'Spell suggest' })
      
      -- Miscellaneous
      keymap('n', '<leader>ft', builtin.colorscheme, { desc = 'Color schemes' })
      keymap('n', '<leader>fq', builtin.quickfix, { desc = 'Quickfix list' })
      keymap('n', '<leader>fl', builtin.loclist, { desc = 'Location list' })
      keymap('n', '<leader>fv', builtin.vim_options, { desc = 'Vim options' })
      keymap('n', '<leader>fa', builtin.autocommands, { desc = 'Auto commands' })
      keymap('n', '<leader>fp', builtin.pickers, { desc = 'Previous pickers' })
      
      -- Resume last picker
      keymap('n', '<leader>f.', builtin.resume, { desc = 'Resume last picker' })
    end,
  },
  
  -- Better sorting performance
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
}