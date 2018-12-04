{- HELP
Configuration file for the cicd-shell
  loginId       : Your Active directory id, by default it is taken from the env variable 'LOGINID'
  defaultStacks : List of stack to use by default when none is specified in the command line
-}

{ loginId = env:LOGINID as Text, defaultStacks = [ "" ] }
