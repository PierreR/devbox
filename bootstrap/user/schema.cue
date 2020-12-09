#theme: {
	color:   string
	ctermbg: string
}

dark: #theme & {
	color:   "dark"
	ctermbg: "239"
}

light: #theme & {
	color:   "light"
	ctermbg: "254"
}

#Config: {
	userEmail:     !=""
	userName:      !=""
	loginId:       !=""
	console:       dark | *light
	defaultStacks: [ string, ...] | *[]
	defaultUI: {
		enable:            bool | *true
		wallpaper:         *"mountain.jpg" | "devbox" | "devbox2" | "solarized" | "abstract-red"
		appLauncherHotkey: string | *"Ctrl+Space"
		netw:              string | *"enp0s3"
	}
	"cicd-shell": bool | *true
	eclipse:      bool | *false
	lorri:        bool | *false
	ocp:          bool | *false
	mr: {
		config?: [ string, ...]
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
	}
}
