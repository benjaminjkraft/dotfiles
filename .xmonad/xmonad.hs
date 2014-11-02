{-# LANGUAGE NoMonomorphismRestriction #-}

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
import XMonad.Config.Desktop (desktopLayoutModifiers)
import XMonad.Config.Gnome
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Place
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
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
main = xmonad $ withUrgencyHook myUrgencyHook $ gnomeConfig
				{ modMask = mod4Mask
        , terminal = "gnome-terminal --window-with-profile=trans"
        , layoutHook = myLayout
        , startupHook = startupHook gnomeConfig >> setWMName "LG3D"
        , manageHook = manageHook gnomeConfig <+> myManageHook
        , keys = \c -> myKeys c `M.union` myManualKeys c `M.union` keys gnomeConfig c
        , workspaces = myWorkspaces
        -- , handleEventHook = mappend myEventHooks (handleEventHook gnomeConfig)
				} `additionalMouseBindings` myMouse

modm = mod4Mask

myUrgencyHook = dzenUrgencyHook
                { args = ["-bg", "darkgreen", "-xs", "1"] }

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
	-- ,	className =? "Firefox" <&&> resource =? "Download" --> doF (W.swapDown)
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
	,	("M-f", spawn "exec firefox")
	,	("M-g", spawn "exec google-chrome")
	,	("M-p a", spawn "exec gnome-control-center")
	,	("M-p n", spawn "exec gnome-control-center network")
	,	("M-p d", spawn "exec gnome-control-center display")
	,	("M-p p", spawn "exec system-config-printer")
	,	("M-p s", spawn "exec gnome-session-properties")
	,	("M-p t", spawn "exec gnome-tweak-tool")
	-- , ("M-b", spawn "~/.bin/boinc")
	-- , ("M-S-b", spawn "~/.bin/boinc off")
	-- , ("M-r", spawn "~/.bin/acrokill")
	-- , ("M-S-r", spawn "~/.bin/rotate")
	-- , ("M-p", sendMessage ToggleStruts)
  , ("M-m", spawn "killall -f MathKernel || killall -f gap.real || killall -f math || killall -f ghc || killall -f sage-ipython")
  -- , ("<XF86AudioPlay>", spawn "~/.bin/spotify-remote playpause")
  -- , ("<XF86AudioPrev>", spawn "~/.bin/spotify-remote previous")
  -- , ("<XF86AudioNext>", spawn "~/.bin/spotify-remote next")
  , ("M-S-s", spawn "killall spotify && spotify")
  , ("M-s", spawn "~/.bin/spotify-remote nowplaying || spotify")
--  , ("<XF86AudioPlay>", spawn "~/.bin/spotify --playpause")
--  , ("<XF86AudioPrev>", spawn "~/.bin/spotify --prev")
--  , ("<XF86AudioNext>", spawn "~/.bin/spotify --next")
--  , ("M-S-s", spawn "~/.bin/spotify")
--  , ("M-s", spawn "~/.bin/spotify --now-playing || ~/.bin/spotify")
  , ("M-z", myPrompt myXPConfig)
	-- , ("M-C-z d", spawn "~/.bin/dmenu")
  , ("M-C-S-z", inputPrompt myXPConfig "$" ?+ (spawn . ("~/.bin/send --no-send-0 "++)))
  , ("M-C-z p", inputPrompt myXPConfig ">>>" ?+ (spawn . (\expr -> "~/.bin/send --title '"++expr++"' python -c 'print "++expr++"'")))
  , ("M-C-z h", inputPrompt myXPConfig "λ>" ?+ (spawn . (\expr -> "~/.bin/send --title '"++expr++"' ghc -e '"++expr++"'")))
  , ("M-C-z m", inputPrompt myXPConfig "stalk" ?+ (spawn . (\expr -> "~/.bin/send --title 'stalk "++expr++"' ~/.bin/stalk "++expr)))
  , ("M-C-z o", inputPromptWithCompl myXPConfig "gnome-open" getDirectoryCompletions ?+ (spawn . (\expr -> "gnome-open '"++expr++"'")))
  , ("M-C-z g", gnomeRun)
  --("M-S-z", gnome-do)  --this isn't necessary here b/c gnome-do does its own activation shortcut
  , ("M-n", spawn "~/.bin/reminder")
--  , ("M-a", spawn "keepass2 --auto-type")
	, ("M-S-h", sendMessage MirrorShrink)
	, ("M-S-l", sendMessage MirrorExpand)
  -- , ("M-e", gotoMenu)
  -- , ("M-S-e", bringMenu)
  , ("M-\\", windows W.focusMaster)
	, ("M-<Left>",    prevWS )
	, ("M-<Right>",   nextWS )
	, ("M-S-<Left>",  shiftToPrev )
	, ("M-S-<Right>", shiftToNext )
	, ("M-C-<Left>",  shiftToPrev >> prevWS)
	, ("M-C-<Right>", shiftToNext >> nextWS)
--  , ("M-S-t", sendMessage ToggleLayout)
--  , ("M-C-c", sendMessage $ escape ToggleLayout)
  , ("M-c f", sendMessage $ JumpToLayout "No Borders Full")
  , ("M-c S-f", sendMessage $ JumpToLayout "Full")
  , ("M-c t", sendMessage $ JumpToLayout "Tall 2")
  , ("M-c S-t", sendMessage $ JumpToLayout "Tall 1.5")
  , ("M-c s", sendMessage $ JumpToLayout "Spiral")
  , ("M-c c", sendMessage $ JumpToLayout "Vertical Chat")
  , ("M-c p", sendMessage $ JumpToLayout "PSet")
  , ("M-c m", sendMessage $ JumpToLayout "Mirror Tall")
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

myLayout = tiled15 ||| tiled2 ||| verticalChat ||| pset ||| mirrorTiled ||| spir ||| noBordersFull ||| full
         where tall2 = ResizableTall 1 0.03 (5/8) [1,1.95]
               tall15 = ResizableTall 1 0.03 (5/8) [1,1.5]
               tiled2 = renamed [Replace "Tall 2"] $ myLayoutModifiers $ tall2
               tiled15 = renamed [Replace "Tall 1.5"] $ myLayoutModifiers $ tall15
               mirrorTiled = renamed [Replace "Mirror Tall"] $ myLayoutModifiers $ Mirror tall15
               spir = renamed [Replace "Spiral"] $ myLayoutModifiers $ mastered 0.03 (5/8) $ spiralWithDir South CCW 0.8
               noBordersFull = renamed [Replace "No Borders Full"] $ noBorders Full
               verticalChat = renamed [Replace "Vertical Chat"] $ myLayoutModifiers $ mastered 0.03 (3/5) $ Mirror $ Tall 1 0.05 (1/2) --GridRatio (1.7) True
               --newMain = renamed [Replace "Main"] $ myLayoutModifiers $ mastered 0.03 0.5 $ ((Mirror $ Tall 1 0.05 (1/2)) ****|* Full) --GridRatio (1.7) True
               pset = renamed [Replace "PSet"] $ myLayoutModifiers $ ResizableTall 2 0.03 (5/8) [1.5,1.9,1.9,1.8]
               full = renamed [Replace "Full"] $ myLayoutModifiers $ Full

myLayoutModifiers = dwmStyle shrinkText myTheme . smartBorders . desktopLayoutModifiers . layoutHintsToCenter

myTheme = defaultTheme --doesn't appear to do anything?

myXPConfig = defaultXPConfig { font = "xft:Ubuntu Mono-10" 
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

commandsFromFile :: FilePath -> IO CommandMap
commandsFromFile path = do
  file <- readFile path `catch` const (return "")
  let commandMap = M.fromList (mapMaybe mapper $ lines file)
  return commandMap
  where mapper line = let (name, cmd) = span (/=' ') line
                      in if null cmd
                            then Nothing
                            else if (and $ zipWith (==) "term" $ tail cmd)
                                    then Just (name, spawn $ "exec gnome-terminal --window-with-profile=trans --working-directory=\""++(drop 6 cmd)++"\"")
                                    else Just (name, spawn $ tail cmd)

getBashOutput :: (MonadIO m) => [String] -> String -> m String
--getBashOutput args s = runProcessWithInput "bash" args ( s++"\n" )
getBashOutput args s = io $ runProcessWithInput "bash" (args++["-c",s]) []

split :: (Eq a) => a -> [a] -> [[a]]
split _ [] = [[]]
split c (x:xs) = if c==x then []:split c xs else let ys = split c xs in if null ys then [[x]] else (x:head ys):tail ys

myPrompt :: XPConfig -> X ()
myPrompt conf = do
  cmdMaps <- io $ sequence [pathCommands, commandsFromFile "/home/ben/.aliases", commandsFromFile "/home/ben/.aliases_dmenu"]
  let cmds = M.unions cmdMaps
  file <- io $ fmap (++"/super-prompt-history") $ getAppUserDataDirectory "xmonad"
  superPrompt 51 file cmds conf

--myInputPrompt :: XPConfig -> X ()
--myInputPrompt conf = inputPrompt conf "$" ?+ \cmd -> do
--  out <- getBashOutput ["-l"] $ cmd++" 2>&1"
--  if not (null out)
--     then do
--       let truncatedOut = init $ unlines $ map (\l -> if length l > 40 then take 47 l ++ "..." else l) $ if length (lines out) > 10 then (take 9 $ lines out)++["..."] else lines out
--       safeSpawn "notify-send" ["-i","gnome-utilities-terminal","\""++cmd++"\" returned:", out]
--     else return ()
  

