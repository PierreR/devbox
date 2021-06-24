package devbox

#theme: {
	background: string
	foreground: string
	ctermbg: string
}

#dark: #theme & {
	background: "#2e3440"
    foreground: "#d8dee9"
	ctermbg: "239"
}

#light: #theme & {
	background: "#fdf6e3"
	foreground: "#657b83"
	ctermbg: "254"
}

#Config: {
	userEmail: !=""
	userName:  !=""
	loginId:   !=""
	console:   *#dark | #light
	defaultStacks: [...string]
	defaultUI: {
		enable:            bool | *true
		wallpaper:         *"mountain.jpg" | "devbox" | "devbox2" | "solarized" | "abstract-red"
		appLauncherHotkey: *"Ctrl+Space" | string
		netw:              *"enp0s3" | string
	}
	"cicd-shell": *false | bool
	eclipse:      *false | bool
	lorri:        *false | bool
	ocp:          *false | bool
	mr: {
		config?: [...string]
		repos?: [...string]
	}
	zsh: {
		theme:                 string | *"simple"
		enableCompletion:      bool | *true
		enableAutosuggestions: bool | *false
	}
	vscode: {
		enable:          bool | *true
		manageExtension: bool | *false
		showTabs:        bool | *true
		minimap:         bool | *true
	}
}
