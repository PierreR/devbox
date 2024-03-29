--
-- xmonad config file.
--

import qualified Data.Map                         as M
import           Data.Monoid
import           Graphics.X11.ExtraTypes.XF86
import           System.Exit
-- import           System.Taffybar.Hooks.PagerHints (pagerHints)
import           System.Taffybar.Support.PagerHints (pagerHints)

import           XMonad
import           XMonad.Actions.CycleWS
import qualified XMonad.Actions.GridSelect        as GridSelect
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.SetWMName
import           XMonad.Hooks.UrgencyHook
import           XMonad.Layout.Named
import           XMonad.Layout.ZoomRow
import           XMonad.Layout.NoBorders
import           XMonad.Util.Cursor
import           XMonad.Util.SpawnOnce


import qualified XMonad.StackSet                  as W

-- Some doc
-- .|. is xmonad specific : it is a bitwise "or"


-- Key bindings.
-- myKeys return a Map (associative list)
myKeys conf@XConfig {XMonad.modMask = modm} = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm, xK_t), spawn $ XMonad.terminal conf)

    -- launch README
    , ((0, xK_F1 ), spawn "xdg-open file:///home/vagrant/.local/share/devbox/devbox.html#_minimal_cheat_sheet")

    -- launch editor
    -- , ((modm .|. shiftMask, xK_comma ), spawn "emacsclient -c")
    , ((modm .|. shiftMask, xK_comma ), spawn "code")

    -- resize wallpaper
    , ((modm .|. shiftMask, xK_i), spawn "systemctl --user restart wallpaper.service" )

    -- close focused window
    , ((modm, xK_q     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Expand the master area
    , ((modm,               xK_m     ), sendMessage zoomIn)
    -- Move focus to the master window
    --, ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage zoomOut)

    -- Push window back into tiling
    , ((modm,               xK_w     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io exitSuccess)

    -- Restart xmonad
    , ((modm .|. shiftMask, xK_c     ), spawn "xmonad --recompile; xmonad --restart")

    , ((modm              , xK_Right ), nextWS)
    , ((modm              , xK_Left  ), prevWS)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

-- urgent notification
urgentConfig :: UrgencyConfig
urgentConfig = UrgencyConfig { suppressWhen = Focused, remindWhen = Dont }

myMouseBindings XConfig {XMonad.modMask = modm} = M.fromList

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                      >> windows W.shiftMaster)

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                      >> windows W.shiftMaster)

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = horiz ||| horiz_tiled ||| vert ||| full ||| vert_tiled
  where
     vert_tiled = named "⊢" $ tiled
     horiz_tiled = named "⊤" $ Mirror $ tiled
     full    = named "□" Full
     horiz = named "≡" $ Mirror zoomRow
     vert = named "∥" $ zoomRow
     tiled   = Tall nmaster delta ratio

     nmaster = 1 --  default number of windows in the master pane
     ratio   = 1/2 -- default proportion of screen occupied by master pane
     delta   = 3/100 -- percent of screen to increment by when resizing panes

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
myStartupHook = do
  setWMName "LG3D"

myManageHook =
  composeOne
  [ className =? "Emacs" -?> doShift "1"
  , className =? "Code" -?> doShift "1"
  , className =? "Google-chrome" -?> doShift "9"
  ]
  <>
  composeOne
  [ resource =? "albert" -?> doCenterFloat
  , title =? "Eclipse" -?> doFloat
  ]
  <>
  composeOne
  [ isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH" -?> doIgnore
  , isFullscreen -?> (doF W.focusDown <+> doFullFloat)
  , isDialog -?> doCenterFloat
  ]

azertyKeys conf@XConfig {modMask = modm} = M.fromList $
    ((modm, xK_semicolon), sendMessage (IncMasterN (-1))) :
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (workspaces conf) [0x26,0xe9,0x22,0x27,0x28,0xa7,0xe8,0x21,0xe7,0xe0],
          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

main =
  xmonad $ docks $ ewmh $ pagerHints $ myConfig
  where
    myConfig  = def
      { terminal           = "alacritty"
      , focusFollowsMouse  = False
      , borderWidth        = 1
      , modMask            = mod4Mask
      , workspaces         = ["1","2","3","4","5","6","7","8","9"]
      , normalBorderColor  = "#333333"
      , focusedBorderColor = "#AFAF87"
      , keys               = \c -> azertyKeys c `M.union` myKeys c
      , mouseBindings      = myMouseBindings
      , layoutHook         = (avoidStruts . smartBorders) myLayout
      , handleEventHook    = handleEventHook def <+> fullscreenEventHook
      , startupHook        = myStartupHook <+> ewmhDesktopsStartup
      , manageHook         = manageDocks <+> myManageHook
      , logHook            = ewmhDesktopsLogHook
      }
