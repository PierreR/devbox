{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.taffybar;
in

{
  options = {
    profiles.taffybar = {
      enable = mkEnableOption "Taffybar";
      netw = mkOption {
        default = "enp0s3";
        type = types.str;
      };
    };
  };
  config = mkIf cfg.enable {
    services.taffybar.enable = true;
    home.file = {
      ".config/taffybar/taffybar.hs".text = ''
        -- -*- mode:haskell -*-
        module Main where

        import System.Taffybar (startTaffybar)
        import System.Taffybar.Context (TaffybarConfig(..))
        import System.Taffybar.Hooks
        import System.Taffybar.Information.CPU
        import System.Taffybar.Information.Memory
        import System.Taffybar.SimpleConfig
        import System.Taffybar.Widget
        import System.Taffybar.Widget.Generic.PollingGraph

        transparent = (0.0, 0.0, 0.0, 0.0)
        yellow1 = (0.9453125, 0.63671875, 0.2109375, 1.0)
        yellow2 = (0.9921875, 0.796875, 0.32421875, 1.0)
        green1 = (0, 1, 0, 1)
        green2 = (1, 0, 1, 0.5)
        taffyBlue = (0.129, 0.588, 0.953, 1)

        myGraphConfig =
          defaultGraphConfig
          { graphPadding = 0
          , graphBorderWidth = 1 -- 0
          , graphWidth = 68 -- 75
          , graphBackgroundColor = transparent
          }

        netCfg = myGraphConfig
          { graphDataColors = [yellow1, yellow2]  }

        memCfg = myGraphConfig
          { graphDataColors = [taffyBlue]}

        cpuCfg = myGraphConfig
          { graphDataColors = [green1, green2]}

        memCallback :: IO [Double]
        memCallback = do
          mi <- parseMeminfo
          return [memoryUsedRatio mi]

        cpuCallback = do
          (_, systemLoad, totalLoad) <- cpuLoad
          return [totalLoad, systemLoad]

        main =
          let myWorkspacesConfig =
                defaultWorkspacesConfig
                { minIcons = 1
                , widgetGap = 0
                , showWorkspaceFn = hideEmpty
                }
              workspaces = workspacesNew myWorkspacesConfig
              cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
              mem = pollingGraphNew memCfg 1 memCallback
              net = networkGraphNew netCfg (Just ["${cfg.netw}"])
              clock = textClockNew Nothing "%b %_d %H:%M" 1
              layout = layoutNew defaultLayoutConfig
              windowsW = windowsNew defaultWindowsConfig
              tray = sniTrayNew
              myConfig = defaultSimpleTaffyConfig
                { startWidgets =
                    workspaces : map (>>= buildContentsBox) [ layout, windowsW ]
                , endWidgets = map (>>= buildContentsBox)
                  [ clock, net, mem, cpu]
                , barPosition = Top
                , barPadding = 0
                , barHeight = 30
                , widgetSpacing = 1
                }
          in startTaffybar $ toTaffyConfig myConfig
      '';
    };
  };
}
