{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts #-}

import qualified Control.Exception as E
import Control.Applicative
import Control.Monad
import Data.Binary as B
import Data.Function
import Data.List
import qualified Data.Map as M
import Data.Map ((!), Map)
import Data.Maybe
import Data.Monoid
import Data.Ord
import System.Directory
import System.Environment
import System.FilePath
import System.IO
import System.Process
import System.Time
import XMonad hiding ((|||))
import XMonad.Actions.CycleWS
import qualified XMonad.Actions.FlexibleResize as Flex
import XMonad.Actions.WindowBringer
import XMonad.Config
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Place
import XMonad.Hooks.SetWMName
import XMonad.Layout.Combo
import XMonad.Layout.Column
import XMonad.Layout.DwmStyle
import XMonad.Layout.HintedGrid
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.LayoutHints
import XMonad.Layout.Master
import XMonad.Layout.MessageControl
import XMonad.Layout.Renamed
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spiral as Spiral
import XMonad.Layout.ToggleLayouts
import XMonad.Prompt hiding (pasteString)
import XMonad.Prompt.Input
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedWindows
import XMonad.Util.Run
import XMonad.Util.Paste

-- Run xmonad with the specified conifguration
main = xmonad $ ewmh $ gnomeConfig
        { modMask = mod4Mask
        , terminal = "gnome-terminal --window-with-profile=trans"
        , layoutHook = myLayout
        , startupHook = myGnomeRegister >> startupHook desktopConfig >> setWMName "LG3D"
        -- -- for Splash
        , manageHook = manageHook gnomeConfig <+> myManageHook
        , keys = \c -> myKeys c `M.union` myManualKeys c `M.union` keys gnomeConfig c
        , workspaces = myWorkspaces
        -- , handleEventHook = mappend myEventHooks (handleEventHook gnomeConfig)
        } `additionalMouseBindings` myMouse

modm = mod4Mask

myGnomeRegister :: MonadIO m => m ()
myGnomeRegister = io $ do
    x <- lookup "DESKTOP_AUTOSTART_ID" `fmap` getEnvironment
    whenJust x $ \sessionId -> safeSpawn "dbus-send"
        [ "--session"
        , "--print-reply=literal"
        , "--dest=org.gnome.SessionManager"
        , "/org/gnome/SessionManager"
        , "org.gnome.SessionManager.RegisterClient"
        , "string:xmonad"
        , "string:"++sessionId
        ]

-- myEventHooks = []

myManageHook = composeAll $
  [ className =? "Do" --> doIgnore
  , className =? "Googleearth-bin" --> doFloat
  , className =? "Glade" --> doFloat
  , className =? "Pidgin" --> doF (W.focusUp . W.swapDown)
  , className =? "Gnome-terminal" --> doF (W.focusUp . W.swapDown)
  , className =? "Zenity" --> doFloat
  , className =? "Grhino" --> doFloat
  , isFullscreen --> doFullFloat
  , resource =? "RCT.EXE" --> doRectFloat (W.RationalRect (155/1680) (30/1050) (1270/1680) (990/1050))
  , resource =? "explorer.exe" <&&> title =? "EVETQ - Wine desktop" --> doFullFloat
  , className =? "Spotify" --> doShift "0"
  , className =? "Pithos" --> doShift "0"
  , resource =? "steam.exe" --> doShift "0"
  , resource =? "portal2.exe" --> doFullFloat
  , className =? "Transmission-gtk" <&&> title =? "Transmission" --> doShift "0"
  , className =? "Gnome-system-monitor" --> doShift "0"
  , className =? "Boincmgr" --> doShift "0"
  --, fmap not isDialog --> doF avoidMaster
  -- ,  className =? "Firefox" <&&> resource =? "Download" --> doF (W.swapDown)
  -- , className =? "Firefox" <&&> resource =? "Addons" --> doRectFloat (W.RationalRect (1/4) (1/6) (3/4) (2/3))
  ]


avoidMaster = W.modify' $ \c -> case c of
     W.Stack t [] (r:rs) -> W.Stack r [] (t:rs)
     otherwise           -> c

myMouse =
  [ ((modm, button3), (\w -> focus w >> Flex.mouseResizeWindow w))
  --, ((modm, button1), (\w -> focus w >> placeFocused simpleSmart)) --placeFocused seems broken
  ]

myWorkspaces = map show ([1..9]++[0])

myManualKeys = \conf -> M.fromList $
  [ ((0, 0x1008ffa9), spawn "~/.bin/touchpad") --XF86TouchpadToggle
  ]

myKeys = \conf -> mkKeymap conf $
  [ ("M-C-q", spawn "gnome-screensaver-command --lock")
  ,  ("M-f", spawn "exec firefox")
  ,  ("M-g", spawn "exec google-chrome")
  ,  ("M-p a", spawn "exec gnome-control-center")
  ,  ("M-p n", spawn "exec gnome-control-center network")
  ,  ("M-p d", spawn "exec gnome-control-center display")
  ,  ("M-p p", spawn "exec system-config-printer")
  ,  ("M-p s", spawn "exec gnome-session-properties")
  ,  ("M-p t", spawn "exec gnome-tweak-tool")
  ,  ("M-p e", spawn "emoji-keyboard -s")
  , ("M-p k", spawn "emoji-keyboard -k")
  , ("M-z", myPrompt myXPConfig)
  , ("M-C-S-z", inputPrompt myXPConfig "$" ?+ (spawn . ("~/.bin/send --no-send-0 "++)))
  , ("M-C-z p", inputPrompt myXPConfig ">>>" ?+ (spawn . (\expr -> "~/.bin/send --title '"++expr++"' python -c 'print "++expr++"'")))
  , ("M-C-z h", inputPrompt myXPConfig "λ>" ?+ (spawn . (\expr -> "~/.bin/send --title '"++expr++"' ghc -e '"++expr++"'")))
  , ("M-C-z m", inputPrompt myXPConfig "stalk" ?+ (spawn . (\expr -> "~/.bin/send --title 'stalk "++expr++"' ~/.bin/stalk "++expr)))
  , ("M-C-z o", inputPromptWithCompl myXPConfig "gnome-open" getDirectoryCompletions ?+ (spawn . (\expr -> "gnome-open '"++expr++"'")))
  , ("M-C-z g", gnomeRun)
  , ("M-n", spawn "~/.bin/reminder")
  , ("M-S-h", sendMessage MirrorShrink)
  , ("M-S-l", sendMessage MirrorExpand)
  , ("M-\\", windows W.focusMaster)
  , ("M-<Left>",    prevWS )
  , ("M-<Right>",   nextWS )
  , ("M-S-<Left>",  shiftToPrev )
  , ("M-S-<Right>", shiftToNext )
  , ("M-C-<Left>",  shiftToPrev >> prevWS)
  , ("M-C-<Right>", shiftToNext >> nextWS)
  , ("M-c f", sendMessage $ JumpToLayout "No Borders Full")
  , ("M-c S-f", sendMessage $ JumpToLayout "Full")
  , ("M-c S-t", sendMessage $ JumpToLayout "Tall")
  , ("M-c c", sendMessage $ JumpToLayout "Chat")
  , ("M-<Print>", spawn "gnome-screenshot")
  , ("M-S-<Print>", spawn "gnome-screenshot --window")
  , ("M-C-<Print>", spawn "gnome-screenshot --area")
  , ("M-S-C-<Print>", spawn "gnome-screenshot --interactive")
  ]
  ++
  [ ("M-" ++ m ++ k, f i)
  | (i,k) <- zip (cycle $ reverse $ XMonad.workspaces conf) $ reverse (XMonad.workspaces conf)++["`"]
  , (f,m) <-
    [ (windows . W.view, "")
    , (windows . W.shift, "S-")
    , (\w -> (windows $ W.shift w) >> (windows $ W.view w), "C-")
    ]
  ]

myLayout = tiled ||| verticalChat ||| noBordersFull ||| full
         where tiled = renamed [Replace "Tall"] $ myLayoutModifiers $ ResizableTall 1 0.03 0.7 [1,1.5]
               noBordersFull = renamed [Replace "No Borders Full"] $ noBorders Full
               verticalChat = renamed [Replace "Chat"] $ myLayoutModifiers $ mastered 0.03 (3/5) $ Mirror $ Tall 1 0.05 (1/2) --GridRatio (1.7) True
               full = renamed [Replace "Full"] $ myLayoutModifiers $ Full

myLayoutModifiers = dwmStyle shrinkText myTheme . smartBorders . desktopLayoutModifiers . layoutHintsToCenter

myTheme = defaultTheme --doesn't appear to do anything?

myXPConfig = defaultXPConfig { font = "xft:Ubuntu Mono-11" 
                             , height = 30
                             , promptBorderWidth = 0
                             , position = Top
                             , bgColor = "#303030"
                             , fgColor = "#b0b0b0"
                             , bgHLight = "#e0e0e0"
                             , fgHLight = "#000000"
                             }

expandHomeTilde :: String -> IO String
expandHomeTilde "~" = getEnv "HOME"
expandHomeTilde ('~':'/':xs) = fmap (</> xs) $ getEnv "HOME"
expandHomeTilde xs = return xs

getDirectoryCompletions :: String -> IO [String]
getDirectoryCompletions "" = getDirectoryCompletions "~"
getDirectoryCompletions path = do
    expath <- expandHomeTilde path
    exists <- doesDirectoryExist expath
    if exists && ('.'/=last expath)
      then do
        cont <- getDirectoryContentsWithSlashes expath 
        return $ map (path </>) $ filter ((/='.') . head) cont
      else do
        cont <- getDirectoryContentsWithSlashes $ dropFileName expath
        return $ map (dropFileName path </>) $ filter (takeFileName expath `isPrefixOf`) cont

getDirectoryContentsWithSlashes :: String -> IO [String]
getDirectoryContentsWithSlashes path = getDirectoryContents path >>= mapM addSlash
  where addSlash :: String -> IO String
        addSlash x = do
          exists <- doesDirectoryExist $ path </> x
          return $ if exists then x++"/" else x

complMatches :: String -> String -> Bool
complMatches "" ('.':ys) = False
complMatches "" _ = True
complMatches xs ys = xs `isPrefixOf` ys

data SuperPrompt = SuperPrompt

type CommandMap = Map String (X ())
type HistMap = Map String Double

instance B.Binary ClockTime where
  put (TOD x y) = B.put x >> B.put y
  get = liftM2 TOD B.get B.get

instance XPrompt SuperPrompt where
  showXPrompt _ = ""

catch :: IO a -> (E.IOException -> IO a) -> IO a
catch = E.catch

superPrompt :: Int -> FilePath -> CommandMap -> XPConfig -> X ()
superPrompt max historyPath commands conf = do
  (t0,histMap) <- io $ catch (B.decodeFile historyPath) (const $ fmap (flip (,) M.empty) getClockTime) :: X (ClockTime, HistMap)
  let useHistMap = M.mapWithKey (\k _ -> M.findWithDefault 0 k histMap) commands :: HistMap
      newHistMap = M.union histMap $ (M.map (const 0) commands)
      sortedNames = map fst $ sortBy (flip $ comparing snd) $ M.assocs useHistMap
  mkXPrompt SuperPrompt conf (mkComplFunFromList' sortedNames) $ \chosen -> do
    t <- io $ getClockTime
    let dt = tdSec $ diffClockTimes t t0
        decayedHistMap = M.map (*((1/2) ** (fromIntegral dt/2500000))) $ M.adjust (\x -> x+1/(x+1)) chosen newHistMap
    io $ B.encodeFile historyPath (t,decayedHistMap)
    commands!chosen

pathCommands :: IO CommandMap
pathCommands = do
  path <- getBashOutput ["-l"] "echo $PATH"
  let dirs = split ':' $ filter (/='\n') path
  commandsRaw <- forM dirs $ \d -> do
    exists <- doesDirectoryExist d
    if exists
       then fmap (map $ (,) d) $ getDirectoryContents d
       else return []
  let commands = filter ((/= '.') . head . snd) $ concat commandsRaw
      commandMap = M.fromListWith const $ map (\(d,cmd) -> (cmd, spawn $ "exec "++(d </> cmd))) commands
  return commandMap

getBashOutput :: (MonadIO m) => [String] -> String -> m String
--getBashOutput args s = runProcessWithInput "bash" args ( s++"\n" )
getBashOutput args s = io $ runProcessWithInput "bash" (args++["-c",s]) []

split :: (Eq a) => a -> [a] -> [[a]]
split _ [] = [[]]
split c (x:xs) = if c==x then []:split c xs else let ys = split c xs in if null ys then [[x]] else (x:head ys):tail ys

myPrompt :: XPConfig -> X ()
myPrompt conf = do
  cmdMap <- io $ pathCommands
  file <- io $ fmap (++"/super-prompt-history") $ getAppUserDataDirectory "xmonad"
  superPrompt 51 file cmdMap conf
