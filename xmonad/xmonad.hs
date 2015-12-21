import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.WorkspaceByPos
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig
import XMonad.Util.Scratchpad
import XMonad.Util.WorkspaceCompare
import XMonad.Util.Cursor
import System.IO
import Data.List
import Control.Monad (liftM2)
import qualified XMonad.StackSet as W

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar /home/yanjialei/.xmonad/.xmobarrc"
    xmonad $ defaultConfig
        { workspaces = myWorkspaces
        , manageHook = myManageHook <+> manageHook defaultConfig
        , layoutHook = avoidStruts $ layoutHook defaultConfig
		, modMask = mod4Mask
--		, terminal = "xterm -rv"
		, terminal = "sakura"
		, startupHook = myStartupHook
--		, logHook = myLogHook
        }
		`additionalKeys` myKeys



myKeys = [ ((mod4Mask, xK_F12), windows $ W.greedyView "12")
		 , ((mod4Mask, xK_F11), windows $ W.greedyView "11")
		 , ((mod4Mask, xK_F10), windows $ W.greedyView "10")
		 , ((mod4Mask, xK_F9), windows $ W.greedyView "9")
		 , ((mod4Mask, xK_F8), windows $ W.greedyView "8")
		 , ((mod4Mask, xK_F7), windows $ W.greedyView "7")
		 , ((mod4Mask, xK_F6), windows $ W.greedyView "6")
		 , ((mod4Mask, xK_F5), windows $ W.greedyView "5:app")
		 , ((mod4Mask, xK_F4), windows $ W.greedyView "4:pdf")
		 , ((mod4Mask, xK_F3), windows $ W.greedyView "3:text")
		 , ((mod4Mask, xK_F2), windows $ W.greedyView "2:web")
		 , ((mod4Mask, xK_F1), windows $ W.greedyView "1:term")
		 , ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
		 , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
		 , ((0, xK_Print), spawn "scrot")
		 , ((mod4Mask, xK_Right), moveTo Next (WSIs notSP))
		 , ((mod4Mask, xK_Left), moveTo Prev (WSIs notSP))
		 , ((mod4Mask .|. shiftMask, xK_Right), shiftTo Next (WSIs notSP))
		 , ((mod4Mask .|. shiftMask, xK_Left), shiftTo Prev (WSIs notSP))
		 , ((mod4Mask .|. controlMask, xK_Right), windows . W.greedyView =<< findWorkspace getSortByIndexNoSP Next HiddenNonEmptyWS 1)
		 , ((mod4Mask .|. controlMask, xK_Left), windows . W.greedyView =<< findWorkspace getSortByIndexNoSP Prev HiddenNonEmptyWS 1)
		 ]
  where notSP = (return $ ("SP" /=) .W.tag) :: X (WindowSpace -> Bool)
        shiftAndView dir = findWorkspace getSortByIndexNoSP dir (WSIs notSP) 1 >>= \t -> (windows . W.shift $ t) >> (windows . W.greedyView $ t)
        getSortByIndexNoSP = fmap (.scratchpadFilterOutWorkspace) getSortByIndex

myWorkspaces = ["1:term","2:web","3:text","4:pdf","5:app","6","7","8","9","10","11","12"]

--myLogHook = dynamicLog

myManageHook = composeAll
     [ className =? "firefox" --> viewShift "2:web" 
     , manageDocks
     ]
  where viewShift = doF . liftM2 (.) W.greedyView W.shift

onScr :: ScreenId -> (WorkspaceId -> WindowSet -> WindowSet) -> WorkspaceId -> X ()
onScr n f i = screenWorkspace n >>= \sn -> windows (f i . maybe id W.view sn)

myStartupHook = do
 setDefaultCursor xC_left_ptr
 spawnOnce "fcitx -r -d"
-- onScr 1 W.greedyView "2:web"

