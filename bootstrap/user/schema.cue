#theme: {
	color:   string
	ctermbg: string
}

#dark: #theme & {
	color:   "dark"
	ctermbg: "239"
}

#light: #theme & {
	color:   "light"
	ctermbg: "254"
}

#Config: {
	userEmail:     !=""
	userName:      !=""
	loginId:       !=""
	console:       *#dark | #light
	defaultStacks: [...string]
	defaultUI: {
		enable:            bool | *true
		wallpaper:         *"mountain.jpg" | "devbox" | "devbox2" | "solarized" | "abstract-red"
		appLauncherHotkey: *"Ctrl+Space" | string
		netw:              *"enp0s3" | string
	}
	"cicd-shell": *true  | bool
	eclipse:      *false | bool
	lorri:        *false | bool
	ocp:          *false | bool
	mr: {
		config?: [...string]
		repos?: [ string, ...]
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
