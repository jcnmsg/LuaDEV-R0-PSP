function save() 
    mydata = {
        "nick='João'", 
        "age=24", 
        "health='20'", 
        "level='2'"
    }; 

    mysavedata = table.concat(mydata, "[SEPARATOR]"); --legacy: mydata:implode() broke

    spaces = { "DATA0", "DATA1", "DATA2" };
    saveplace = {gameid="DEMODEV1", savenames=spaces};
    saveconfig = {title="Demo", subtitle=os.date(), details="Saved player details", savetext="New stuff!"}
    done, where = savedata.save(saveplace,saveconfig,mysavedata);
    if done then
        return where
    end

    return nil
end

function load() 
    spaces = {"DATA0", "DATA1", "DATA2" };
    saveplace = {gameid="DEMODEV1", savenames=spaces};
    done, where, what = savedata.load(saveplace);
    if done then
        if what ~= nil then
            return what:explode("[SEPARATOR]");
        end
    end

    return nil   
end

if not save() then
    os.message("Save was canceled. Did you press O?");
end

data = load();

if data then
    for i=1,#data do
        assert(loadstring(data[i]))(); -- execute lua code, saved in savedata.
    end

    os.message("Welcome back, "..nick.."!");
end 