-- Read and write to a .INI file
myinifile = ini.load("config.ini", true);
myname = myinifile:read("PROFILE","name", os.nick());
myage = myinifile:read("PROFILE","age",0);
myage = myage + 1;
myinifile:write("PROFILE","age",myage);
myinifile:free();
myinifile = nil;