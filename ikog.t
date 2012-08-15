#!<^DATA
# send mail to coupan owner when coupan gets used  @Anywhere :pNone :created2009-03-10
#!<^CONFIG
cfgColor = 1
cfgAutoSave = True
cfgReviewMode = False
cfgSysCalls = False
cfgEditorNt = "edit"
cfgEditorPosix = "nano,pico,vim,emacs"
cfgShortcuts = ['', '', '', '', '', '', '', '', '', '']
cfgAbbreviations = {'@C': '@Computer', '@A': '@Anywhere', '@Pw': '@Password', '@D': '@Desk', '@E': '@Errands', '@H': '@Home', '@I': '@Internet', '@N': '@Next', '@O': '@Other', '@L': '@Lunch', '@M': '@Meeting', '@S': '@Someday/Maybe', '@P': '@Phone', '@W': '@Work', '@W4': '@Waiting_For'}
cfgPAbbreviations = {':Pi': ':pImport', ':P1': ':pI18N', ':Pw': ':pWebsite'}
#!<^CODE
magicTag = "#!<^"
gMaxLen = 80
try:
    ruler   = "~".ljust(gMaxLen - 1, "~")
    divider = "_".ljust(gMaxLen - 1, "_")
except Exception:
    print "Error found.  Probably wrong version of Python"

def safeRawInput(prompt): entry = raw_input(prompt)

### global compare function
def compareTodo(a, b):
    return cmp(a.getEffectivePriority(), b.getEffectivePriority())

def printError(msg):
    print gColor.code("error") + "ERROR: " + msg + gColor.code("normal")

def clearScreen(useSys = False): pass

### XTEA algorithm public domain
class Xtea:
    """
    http://www.movable-type.co.uk/scripts/tea.html
    """
    def __init__(self):
        pass

    def crypt(self, key,data,iv='\00\00\00\00\00\00\00\00',n=32):
        def keygen(key,iv,n):
            while True:
                iv = self.xtea_encrypt(key,iv,n)
                for k in iv:
                    yield ord(k)
        xor = [ chr(x^y) for (x,y) in zip(map(ord,data),keygen(key,iv,n)) ]
        return "".join(xor)

    def xtea_encrypt(self, key,block,n=32):
        v0,v1 = struct.unpack("!2L",block)
        k = struct.unpack("!4L",key)
        sum,delta,mask = 0L,0x9e3779b9L,0xffffffffL
        for round in range(n):
            v0 = (v0 + (((v1<<4 ^ v1>>5) + v1) ^ (sum + k[sum & 3]))) & mask
            sum = (sum + delta) & mask
            v1 = (v1 + (((v0<<4 ^ v0>>5) + v0) ^ (sum + k[sum>>11 & 3]))) & mask
        return struct.pack("!2L",v0,v1)

class WordWrapper:
    def __init__(self, width):
        self.width = width
        self.nLines = 0
        self.pos = 0

    def addLine(self, pos):
        self.pos = pos
        self.nLines = self.nLines + 1

    def getNLines(self):
        return self.nLines

    def intelliLen(self, text):
       return len(gColor.stripCodes(text))

    def wrap(self, text):
        self.nLines = 0
        formatted = text.replace("<br>", "\n").replace("<BR>", "\n")
        lines = formatted.splitlines()
        out = ""
        self.pos = 0
        for thisline in lines:
            newline = True
            words = thisline.split()
            if self.pos != 0:
                out = out + "\n"
                self.addLine(0)
            for w in words:
                wlen = self.intelliLen(w) + 1
                if (self.pos + wlen) == self.width:
                    out = out + " " + w
                    self.addLine(0)
                elif (self.pos + wlen) < self.width:
                    if newline:
                        out =  out + w
                        self.pos = wlen
                    else:
                        out = out + " " + w
                        self.pos = self.pos + wlen + 1
                else:
                    out = out + "\n" + w
                    self.addLine(wlen)
                newline = False
        return out

### Viewer class for paging through multiple lines
class ListViewer:
    def __init__(self, maxlines):
        self.maxlines = maxlines

    def show(self, list, pause):
        count = 0
        for line in list:
            if count >= self.maxlines or line == pause:
                io = safeRawInput("--- Press enter for more. Enter s to skip ---").strip()
                print ""
                if len(io) > 0 and io.upper()[0] == "S":
                    break
                count = 0
            if line != pause:
                print line
            count = count + 1

### Handler for encryption
class Encryptor:
    TYPE_OBSCURED = "xtea_"
    TYPE_AES = "aes_"
    SALT_64 = "1hJ8*gpQ"

    def __init__(self):
        self.key = ""
        self.encryptionType = self.TYPE_OBSCURED

    def setType(self, codeType):
        if codeType == self.TYPE_AES and supportAes == False:
            self.encryptionType = self.TYPE_OBSCURED
        else:
            self.encryptionType = codeType
        return self.encryptionType

    def setKey(self, key):
        self.key = key

    def getKey(self):
        return self.key

    def enterKey(self, prompt1, prompt2):
        done = False
        while not done:
            input1 = getpass.getpass(prompt1 + " >>>")
            if prompt2 != "":
                input2 = getpass.getpass(prompt2 + " >>>")
                if input1 != input2:
                    print "You must enter the same password.  Start again"
                else:
                    done = True
            else:
                done = True
        self.key = input1
        return input1

    def complexKey(self):
        return md5(self.key).digest()

    def getSecurityClass(self, encrypted):
        if encrypted.startswith(self.TYPE_OBSCURED):
            return "private xtea"
        if encrypted.startswith(self.TYPE_AES):
            return "secret aes"
        return "unknown"

    def obscure(self, plainText):
        key = self.complexKey()
        obscured = Xtea().crypt(key, plainText, self.SALT_64)
        return self.TYPE_OBSCURED + obscured.encode('hex_codec')

    def unobscure(self, obscured):
        plain = ""
        data = obscured[len(self.TYPE_OBSCURED):]
        data = data.decode('hex_codec')
        key = self.complexKey()
        plain = Xtea().crypt(key, data, self.SALT_64)
        return plain

    def encryptAes(self, plainText):
        if len(self.key) < 16:
            key = self.complexKey()
        else:
            key = self.key
        obscured = pyRijndael.EncryptData(key, plainText)
        return self.TYPE_AES + obscured.encode('hex_codec')

    def decryptAes(self, encrypted):
        plain = ""
        data = encrypted[len(self.TYPE_AES):]
        data = data.decode('hex_codec')
        if len(self.key) < 16:
            key = self.complexKey()
        else:
            key = self.key
        plain = pyRijndael.DecryptData(key, data)
        return plain

    def enterKeyAndEncrypt(self, plainText):
        self.enterKey("Enter the master password.", "Re-enter the master password")
        return self.encrypt(plainText)

    def encrypt(self, plainText):
        if self.encryptionType == self.TYPE_AES:
            return self.encryptAes(plainText)
        else:
            return  self.obscure(plainText)

    def enterKeyAndDecrypt(self, encryptedText):
        self.enterKey("Enter your master password", "")
        return self.decrypt(encryptedText)

    def decrypt(self, encryptedText):
        if encryptedText.startswith(self.TYPE_AES):
            if not supportAes:
                return "You do not have the pyRinjdael module so the text cannot be decrypted."
            else:
                return self.decryptAes(encryptedText)
        else:
            return self.unobscure(encryptedText)

### Handler for user input
class InputParser:
    def __init__(self, prompt):
        self.prompt = prompt

    def read(self, entry = ""):
        if entry == "":
            entry = safeRawInput(self.prompt)
        entry = entry.strip()
        if entry == "":
            command = ""
            line = ""
        else:
            if entry.find(magicTag) == 0:
                printError("You cannot begin lines with the sequence " + magicTag)
                command = ""
                line = ""
            elif entry.find(TodoItem.ENCRYPTION_MARKER) >= 0:
                printError ("You cannot use the special sequence " + TodoItem.ENCRYPTION_MARKER)
                command = ""
                line = ""
            else:
                n = entry.find(" ")
                if n >= 0:
                    command = entry[:n]
                    line = entry[n + 1:]
                else:
                    command = entry
                    line = ""

        return (command, line)

class EditorLauncher:
    WARNING_TEXT = "# Do not enter secret or private information!"
    def __init__(self):
        pass

    def edit(self, text):
        ed = ""
        terminator = "\n"
        if os.name == "posix":
            ed = cfgEditorPosix
        elif os.name == "nt":
            ed = cfgEditorNt
            terminator = "\r\n"
        if ed == "":
            printError("Sorry, but external editing not supported on " + os.name.upper())
            success = False
        else:
            fname = self.makeFile(text, terminator)
            if fname == "":
                printError("Unable to create temporary file.")
            else:
                success = self.run(ed, fname)
                if success:
                    (success, text) = self.readFile(fname)
                if text == self.orgText:
                    print("No changes made.");
                    success = False
                self.scrubFile(fname)
        if success:
            return text
        else:
            return ""

    def scrubFile(self, fname):
        try:
            os.remove(fname)
        except Exception, e:
            printError("Failed to remove file " + fname + ". If you entered any private data you should delete this file yourself.")

    def readFile(self, fname):
        success = False
        try:
            fh = open(fname, "rt")
            line = fh.readline()
            text = ""
            first = True
            while line != "":
                thisLine = self.safeString(line)
                if thisLine != self.WARNING_TEXT:
                    if not first:
                        text = text + "<br>"
                    text = text + thisLine
                    first = False
                line = fh.readline()
            fh.close()
            success = True
        except Exception, e:
            printError("Error reading the edited text. " + str(e))
        return (success, text)

    def safeString(self, text):
        return text.replace("\r","").replace("\n","")

    def makeFile(self, text, terminator):
        fname = ""
        (fh, fname) = tempfile.mkstemp(".tmpikog","ikog")
        fout = os.fdopen(fh,"wt")
        text = text.replace("<BR>", "<br>")
        self.orgText = text
        lines = text.split("<br>")
        fout.write(self.WARNING_TEXT + terminator)
        for thisline in lines:
            fout.write(self.safeString(thisline) + terminator)
        fout.close()
        return fname

    def run(self, program, file):
        progs = program.split(",")
        for prog in progs:
            success = self.runProgram(prog.strip(), file)
            if success:
                break;
        return success

    def runProgram(self, program, file):
        success = False
        if os.name == "posix":
            try:
                progarg = program
                os.spawnlp(os.P_WAIT, program, progarg, file)
                success = True
            except os.error:
                pass
            except Exception, e:
                printError(str(e))
        elif os.name == "nt":
            if file.find(" ") >= 0:
                file = "\"" + file + "\""
            for path in os.environ["PATH"].split(os.pathsep):
                try:
                    prog = os.path.join(path, program)
                    if prog.find(" ") >= 0:
                        progarg = "\"" + prog + "\""
                    else:
                        progarg = prog
                    os.spawnl(os.P_WAIT, prog, progarg, file)
                    success = True
                    if success:
                        break
                except os.error:
                    pass
                except Exception, e:
                    printError(str(e))
        return success


### The main todo list
class TodoList:
    MOVE_DOWN = 0
    MOVE_UP = 1
    MOVE_TOP = 2
    MAX_SHORTCUTS = 10

    def __init__(self, todoFile, externalDataFile):
        self.setShortcuts()
        self.dirty = False
        self.code = []
        self.todo = []
        self.autoSave = True
        self.review = True
        self.sysCalls = False
        self.currentTask = 0
        self.globalFilterText = ""
        self.globalFilters = []
        self.localFilterText = ""
        self.localFilters = []
        # split the file into the source code and the todo list
        self.filename = todoFile
        try:
            self.filename = os.readlink(todoFile)
        except Exception:
            pass # probably windows
        externalDataFile = self.makeFilename(externalDataFile)
        self.externalData = self.findDataSource(externalDataFile)
        if self.externalData:
            self.filename = externalDataFile
        else:
            self.splitFile(self.filename, False)
        self.exactPriority = False
        self.htmlFile = ""

    def setPAbbreviation(self, line):
        save = False
        elements = line.split(" ", 1)
        if not elements[0].lower().startswith(":p"):
            self.showError("Project abbreviations must begin with :p")
        elif len(elements) > 1:
            if not elements[1].lower().startswith(":p"):
                abb = ":p" + elements[1].title()
            else:
                abb = ":p" +elements[1][2:].title()
            globalPAbbr.addAbbreviation(elements[0], abb)
            save = True
        else:
            if not globalPAbbr.removeAbbreviation(elements[0]):
                self.showError("Could not find project abbreviation " + line)
            else:
                print "Project abbreviation ", line, " removed."
                save = True
        return save

    def showPAbbreviations(self):
        print globalPAbbr.toStringVerbose()

    def setAbbreviation(self, line):
        save = False
        elements = line.split(" ", 1)
        if not elements[0].startswith("@"):
            self.showError("Abbreviations must begin with @")
        elif len(elements) > 1:
            if not elements[1].startswith("@"):
                abb = "@" + elements[1].title()
            else:
                abb = "@" +elements[1][1:].title()
            globalAbbr.addAbbreviation(elements[0], abb)
            save = True
        else:
            if not globalAbbr.removeAbbreviation(elements[0]):
                self.showError("Could not find abbreviation " + line)
            else:
                print "Abbreviation ", line, " removed."
                save = True
        return save

    def showAbbreviations(self):
        print globalAbbr.toStringVerbose()

    def setShortcut(self, line, force = False):
        elements = line.split(" ", 1)
        try:
            index = int(elements[0])
            if len(elements) > 1:
                command = elements[1]
            else:
                command = ""
        except Exception, e:
            self.showError("Did not understand the command.  Format should be SHORTCUT N my command.")
            return False

        if index < 0 or index > len(self.shortcuts):
            self.showError("The maximum number of shortcuts is " + str(len(self.shortcuts)) + ". Shortcuts ignored.")
            return False
        else:
            if self.shortcuts[index] != "" and not force:
                if safeRawInput("Do you want to change the current command '" + self.shortcuts[index] + "'? Enter Yes to overwrite. >>>").upper() != "YES":
                    return False
            self.shortcuts[index] = command
            return True


    def showShortcuts(self):
        index = 0
        for s in self.shortcuts:
            if s == "":
                msg = "unused"
            else:
                msg = s
            print "=%1d %s" %(index, msg)
            index = index + 1

    def setShortcuts(self, settings = []):
        if len(settings) > self.MAX_SHORTCUTS:
            self.showError("The maximum number of shortcuts is " + str(self.MAX_SHORTCUTS) + ". Shortcuts ignored.")
        self.shortcuts = ["" for n in range(self.MAX_SHORTCUTS)]
        if len(settings) > 0:
            self.shortcuts[0:len(settings)] = settings

    def getShortcutIndex(self, command):
        if len(command) == 2 and command[0:1].upper() == "=":
            index = ord(command[1]) - ord("0")
            if index >= self.MAX_SHORTCUTS:
                index = -1
        else:
            index = -1
        return index

    def getShortcut(self, command):
        index = self.getShortcutIndex(command)
        if index >= 0:
            return self.shortcuts[index]
        else:
            return ""

    def safeSystemCall(self, line):
        words = line.split()
        if len(words) == 0:
            self.showError("Nothing to do.")
        elif words[0].upper() == "RM" or words[0].upper() == "RMDIR" or words[0].upper() == "DEL":
            self.showError("Sorry, but deletion commands are not permitted.")
        else:
            os.system(line)
            self.pause()

    def processCfgLine(self, line):
        params = line.split("=")
        if len(params) < 2:
            return
        cmd = params[0].strip()
        if cmd == "cfgEditorNt":
            global cfgEditorNt
            cfgEditorNt = params[1].replace("\"", "").strip()
        elif cmd == "cfgEditorPosix":
            global cfgEditorPosix
            cfgEditorPosix = params[1].replace("\"", "").strip()
        elif cmd == "cfgShortcuts":
            elements = params[1].strip()[1:-1].split(",")
            index = 0
            for e in elements:
                self.setShortcut(str(index) + " " + e.strip()[1:-1], True)
                index = index + 1
        elif cmd == "cfgAutoSave":
            if params[1].upper().strip() == "TRUE":
                as_ = True
            else:
                as_ = False
            self.setAutoSave(as_, False)
        elif cmd == "cfgReviewMode":
            if params[1].upper().strip() == "TRUE":
                self.setReview("ON")
            else:
                self.setReview("OFF")
        elif cmd == "cfgSysCalls":
            if params[1].upper().strip() == "TRUE":
                self.setSysCalls("ON")
            else:
                self.setSysCalls("OFF")
        elif cmd == "cfgColor":
            gColor.setCodeSet(int(params[1].strip()))
        elif cmd == "cfgAbbreviations":
            abbrs = eval(params[1].strip())
            globalAbbr.setAbbreviations(abbrs)
        elif cmd == "cfgPAbbreviations":
            abbrs = eval(params[1].strip())
            globalPAbbr.setAbbreviations(abbrs)
        else:
            self.showError("Unrecognised command "  + cmd)

    def makeFilename(self, name):
        (root, ext) = os.path.splitext(name)
        if ext.upper() != ".DAT":
            name = name + ".dat"
        try:
            name = os.path.expanduser(name)
        except Exception, e:
            self.showError("Failed to expand path. " + str(e))
        return name

    def findDataSource(self, filename):
        success = False

        try:
            self.splitFile(filename, False)
            print "Using external data file ", filename
            success = True
        except IOError:
            print "No external data file ", filename, ", so using internal tasks."
        return success

    def setSysCalls(self, mode):
        oldCalls = self.sysCalls
        mode = mode.strip().upper()
        if mode == "ON":
            self.sysCalls = True
            print "Using system calls for clear screen"
        elif mode == "OFF":
            self.sysCalls = False
            print "No system calls for clear screen"
        else:
            self.showError("Could not understand the sys command.  Use SYS ON or OFF.")
        return (self.sysCalls != oldCalls)

    def setAutoSave(self, as_, save):
        if as_:
            if self.autoSave == False:
                self.autoSave = True
                if save:
                    self.save("")
        elif self.autoSave == True:
            self.autoSave = False
            if save:
                self.save("")
        if self.autoSave:
            print "Autosave is on."
        else:
            print "Autosave is off."


    def showError(self, msg):
        printError(msg)

    def pause(self, prompt = "Press enter to continue."):
        if safeRawInput(prompt).strip() != "":
            print "Entry ignored!"

    def setReview(self, mode):
        oldReview = self.review
        mode = mode.strip().upper()
        if mode == "ON":
            self.review = True
            print "In review mode.  Enter advances to the next task"
        elif mode == "OFF":
            self.review = False
            print "Review mode off.  Enter re-displays the current task"
        else:
            self.showError("Could not understand the review command.  Use REVIEW ON or OFF.")
        return (self.review != oldReview)

    def sortByPriority(self):
        self.todo.sort(key=TodoItem.getEffectivePriority, reverse = True)


    def run(self, commandList):
        if not supportAes:
            print "AES encryption not available."
        print("\nEnter HELP for instructions.")

        done = False
        printCurrent = True
        self.sortByPriority()
        reopen = ""
        enteredLine = ""
        truncateTask = False
        while not done:
            self.checkCurrentTask()
            if printCurrent:
                self.moveToVisible()
                print ruler
                if truncateTask:
                    self.printItemTruncated(self.currentTask, "Current: ")
                else:
                    self.printItemVerbose(self.currentTask)
                print ruler
            printCurrent= True
            truncateTask = False
            if self.dirty:
                prompt = "!>>"
            else:
                prompt = ">>>"
            if len(commandList) >= 1:
                enteredLine = commandList[0]
                commandList = commandList[1:]
                print enteredLine
            (rawcommand, line) = InputParser(prompt).read(enteredLine)
            enteredLine = ""
            command = rawcommand.upper()
            if self.getShortcutIndex(command) >= 0:
                sc = self.getShortcut(command)
                if sc != "":
                    (rawcommand, line) = InputParser("").read(self.getShortcut(command))
                else:
                    rawcommand = ""
                    line = ""
                    continue
                print "Shortcut: ", rawcommand, " ", line
            command = rawcommand.upper()
            if command == "":
                if self.review:
                    self.incTaskLoop()
            elif command == "PAB":
                if line.strip() == "?":
                    self.showPAbbreviations()
                elif self.setPAbbreviation(line):
                    self.save("")
            elif command == "ABBREV" or command == "AB":
                if line.strip() == "?":
                    self.showAbbreviations()
                elif self.setAbbreviation(line):
                    self.save("")
            elif command == "SHORTCUT" or command == "SC":
                if line.strip() == "?":
                    self.showShortcuts()
                else:
                    if self.setShortcut(line):
                        self.save("")
                printCurrent = False
            elif command == "2":
                enteredLine = self.runTimer(2)
                printCurrent = False
            elif command == "CLS" or command == "CLEARSCREEN":
                clearScreen(self.sysCalls)
            elif command == "SETEDNT":
                global cfgEditorNt
                cfgEditorNt = line
                self.save("")
            elif command == "SETEDPOSIX":
                global cfgEditorPosix
                cfgEditorPosix = line
                self.save("")
            elif command == "SYS":
                if self.setSysCalls(line):
                    self.save("")
            elif command == "!CMD":
                if self.sysCalls:
                    self.safeSystemCall(line)
                else:
                    self.showError("System calls are not allowed.  Use SYS ON to enable them.")
            elif command == "SHOW" or command == "SH":
                self.decrypt(line)
                self.pause("Press enter to clear screen and continue. ")
                clearScreen(self.sysCalls)
            elif command == "VERSION" or command == "VER":
                print notice[0]
            elif command == "SAVE" or command == "S":
                if not self.dirty:
                    print "There's no need to save now.  If the prompt shows >>> "
                    print "then there is nothing to save.  You only need to save if the prompt "
                    print "shows !>>"
                else:
                    self.forceSave("")
            elif command == "NEW":
                filename = self.makeFilename(line)
                if self.createFile(filename):
                    reopen = filename
                    if self.dirty:
                        self.forceSave("")
                    done = True
                printCurrent = False
            elif command == "OPEN" or command == "O":
                filename = self.makeFilename(line)
                reopen = filename
                if self.dirty:
                    self.forceSave("")
                done = True
                printCurrent = False
            elif command == "AUTOSAVE" or command == "AS":
                if line== "":
                    self.showError("You must enter ON or OFF for the autosave command")
                else:
                    self.setAutoSave(line.upper() == "ON", True)
            elif command == "REVIEW" or command == "REV":
                if self.setReview(line):
                    self.save("")
            elif command == "V0":
                if self.setReview("OFF"):
                    self.save("")
            elif command == "V1":
                if self.setReview("ON"):
                    self.save("")
            elif command == "?":
                self.printHelp(self.quickCard)
            elif command == "HELP" or command == "H":
                self.printHelp(self.help)
            elif command == "QUIT" or command == "Q":
                if self.dirty:
                    self.forceSave("")
                done = True
                printCurrent = False
            elif command == "WEB":
                try:
                    webbrowser.open("http://www.henspace.co.uk")
                except Exception, e:
                    self.showError("Unable to launch browser. " + str(e))
            elif command == "COLOR" or command == "COLOUR" or command == "C":
                try:
                    set = int(line, 10)
                except ValueError:
                    set = gColor.ANSI
                if not gColor.isValidSet(set):
                    self.showError("Invalid colour set ignored.")
                elif gColor.setCodeSet(set):
                    self.save("")
            elif command == "MONOCHROME" or command == "MONO":
                if gColor.setCodeSet(gColor.NONE):
                    self.save("")
            elif command == "EXPORT":
                self.exportTasks()
            elif command == "IMPORT":
                if self.importTasks(line):
                    self.save("")
            elif command == "CLEAR" and line == "":
                if self.clear():
                    self.save("")
            elif command == "FILTER" or command == "FI" or command == "=":
                self.setFilterArray(False, line)
            elif command == "NEXT" or command == "N":
                self.incTaskLoop()
            elif command == "PREV" or command == "P":
                self.decTaskLoop()
            elif command == "TOP" or command == "T" or command == "0":
                self.currentTask = 0
                if line != "":
                    self.setFilterArray(True, "")
                    self.showLocalFilter()
                    self.printShortList(line)
                    truncateTask = True
            elif command == "GO" or command == "G":
                self.moveTo(line)
            elif command == "IMMEDIATE" or command == "I" or command == "++":
                newItem = self.createItem(":d+0 " + line)
                if newItem.hasHiddenTask():
                    clearScreen(self.sysCalls)
                if newItem.hasError():
                    print "Errors were found:"
                    print newItem.getError()
                    print "The task was not added."
                    printCurrent = False
                else:
                    self.todo.insert(0, newItem)
                    self.currentTask = 0
                    self.sortByPriority()
                    self.save("")
            elif command == "KILL" or command == "K" or command == "-" or command == "X":
                if self.removeTask(line):
                    self.save("")
            elif command == "ARCHIVE" or command == "DONE":
                if self.archiveTask(line):
                    self.save("")
            elif command == "REP" or command =="R":
                if self.modifyTask(line, TodoItem.REPLACE):
                    self.sortByPriority()
                    self.save("")
                else:
                    printCurrent = False
            elif command == "SUB" or command == "SU":
                if self.substituteText(line):
                    self.sortByPriority()
                    self.save("")
            elif command == "EDIT" or command == "ED":
                if not self.sysCalls:
                    self.showError("External editing needs to use system calls.  Use SYS ON to enable them.")
                elif line == "":
                    self.addTaskExternal()
                elif self.modifyTask(line, TodoItem.MODIFY, externalEditor = True):
                    self.sortByPriority()
                    self.save("")
                else:
                    printCurrent = False
            elif command == "MOD" or command == "M":
                if self.modifyTask(line, TodoItem.MODIFY):
                    self.sortByPriority()
                    self.save("")
                else:
                    printCurrent = False
            elif command == "EXTEND" or command == "E":
                if self.modifyTask(line, TodoItem.APPEND):
                    self.sortByPriority()
                    self.save("")
                else:
                    printCurrent = False
            elif command == "FIRST" or command == "F":
                if self.moveTask(line, self.MOVE_TOP):
                    self.sortByPriority()
                    self.save("")
                    self.currentTask = 0
            elif command == "DOWN" or command == "D":
                if self.moveTask(line, self.MOVE_DOWN):
                    self.sortByPriority()
                    self.save("")
            elif command == "UP" or command == "U":
                if self.moveTask(line, self.MOVE_UP):
                    self.sortByPriority()
                    self.save("")
            elif command == "LIST" or command == "L":
                print ruler
                self.setFilterArray(True, line)
                self.showLocalFilter()
                self.printList(False, "", "")
                self.clearFilterArray(True)
                print ruler
                truncateTask = True
            elif command == "LIST>" or command == "L>":
                self.startHtml("")
                self.setFilterArray(True, line)
                self.showLocalFilter()
                self.printList(False, "", "")
                self.clearFilterArray(True)
                self.endHtml()
            elif command == "@":
                self.listByAction()
                truncateTask = True
            elif command == ":P":
                self.listByProject()
                truncateTask = True
            elif command == ":D":
                self.listByDate()
                truncateTask = True
            elif command == "@>":
                self.startHtml("Report by Context")
                self.listByAction()
                self.endHtml()
            elif command == ":P>":
                self.startHtml("Report by Project")
                self.listByProject()
                self.endHtml()
            elif command == ":D>":
                self.startHtml("Report by Date")
                self.listByDate()
                self.endHtml()
            elif command == "ADD" or command == "A" or command == "+":
                self.addTask(line)
            elif command == "NOTE" or command == "NOTES":
                self.addTask("#0 @Notes " + line)
            elif (len(command) + len(line)) > 10:
                self.addTask(rawcommand + " " + line)
            elif len(command) > 0:
                self.showError("Didn't understand. (Make sure you have a space after the command or your entry is longer than 10 characters)")
                printCurrent = False
        return reopen

    def timeout(self):
        self.timerActive = False
        clearScreen()
        print "\n\x07Timer\x07 complete.\x07\n\x07Press enter to continue.\x07"

    def runTimer(self, delay):
        self.timerActive = True
        t = Timer(delay * 60 , self.timeout)
        t.start()
        s = raw_input(str(delay) + " minute timer running.\nAny entry will cancel the timer:\n>>>")
        if self.timerActive:
            t.cancel()
            print "Timer cancelled."
        elif s != "":
            s = ""
            print "Input discarded as timer has finished."
        return s.strip()

    def addTaskExternal(self):
        exEdit = EditorLauncher()
        entry = exEdit.edit("")
        if entry != "":
            self.addTask(entry)
        else:
            self.showError("Nothing to add")

    def addTask(self, line):
        newItem = self.createItem(line)
        if newItem.hasError():
            print "Errors were found:"
            print newItem.getError()
            print "The task was not added."
            printCurrent = False
        else:
            if newItem.hasHiddenTask():
                clearScreen(self.sysCalls)
            self.todo.append(newItem)
            self.sortByPriority()
            self.save("")

    def checkCurrentTask(self):
        if self.currentTask > len(self.todo) - 1:
            self.currentTask = len(self.todo) - 1
        if self.currentTask < 0:
            self.currentTask = 0

    def writeArchive(self, item):
        success = False
        filename = self.filename + ".archive.dat"
        try:
            if not os.path.exists(filename):
                f = open(filename,"wb")
                f.write("# " + notice[0] + "\n")
                f.write(magicTag + "DATA\n")
            else:
                f = open(filename,"a+b")

            f.write(item.toString())
            f.write("\n")
            f.close()
            print "Tasks archived to " + filename
            success = True
        except Exception, e:
            self.showError("Error trying to archive the tasks.\n" + str(e))
        return success

    def exportTasks(self):
        filename = self.filename + ".tasks.txt"
        try:
            f = open(filename,"wb")
            f.write("# " + notice[0] + "\n")
            f.write(magicTag + "DATA\n")
            for item in self.todo:
                f.write(item.toString())
                f.write("\n")
            f.close()
            print "Tasks exported to " + filename
        except Exception, e:
            self.showError("Error trying to export the file.\n" + str(e))

    def importTasks(self, filename):
        success = False
        orgNTasks = len(self.todo)
        if filename == "":
            self.showError("You must supply the name of the file to import.")
            return success

        try:
            self.splitFile(filename, True)
            if len(self.todo) == orgNTasks:
                self.showError("Failed to find any tasks to import.")
            else:
                success = True
        except Exception, e:
            self.showError("Error importing tasks. " + str(e))
        return success

    def createFile(self, filename):
        success = False
        if os.path.exists(filename):
            self.showError("Sorry but " + filename + " already exists.")
        else:
            try:
                f = open(filename, "wb")
                f.write("#!/usr/bin/env python\n")
                f.write("#" + ruler + "\n")
                f.close()
                success = True
            except Exception, e:
                self.showError("Error trying to create the file " + filename + ". " + str(e))
        return success

    def save(self, filename):
        if filename != "" or self.autoSave:
            self.forceSave(filename)
        else:
            self.dirty = True
            print "Autosave is off, so changes not saved yet."

    def forceSave(self, filename):
        if filename == "":
            filename = self.filename
        tmpFilename = filename + ".tmp"
        backupFilename = filename + ".bak"
        success = False
        try:
            f = open(tmpFilename,"wb")
            f.write("#!/usr/bin/env python\n")
            f.write("# -*- coding: utf-8 -*-\n")
            f.write("#" + ruler + "\n")
            f.write("# Run the script for details of the licence\n")
            f.write("# or refer to the notice section later in the file.\n")
            f.write("#" + ruler + "\n")
            f.write(magicTag + "DATA\n")
            for item in self.todo:
                f.write(item.toString())
                f.write("\n")
            f.write(magicTag + "CONFIG\n")
            f.write("cfgColor = " + str(gColor.getCodeSet()) + "\n")
            f.write("cfgAutoSave = " + str(self.autoSave) + "\n")
            f.write("cfgReviewMode = " + str(self.review) + "\n")
            f.write("cfgSysCalls = " + str(self.sysCalls) + "\n")
            f.write("cfgEditorNt = \"" + cfgEditorNt + "\"\n")
            f.write("cfgEditorPosix = \"" + cfgEditorPosix + "\"\n")
            f.write("cfgShortcuts = " + str(self.shortcuts) + "\n")
            f.write("cfgAbbreviations = " +str(globalAbbr.toString()) +"\n")
            f.write("cfgPAbbreviations = " +str(globalPAbbr.toString()) +"\n")
            f.write(magicTag + "CODE\n")
            for codeline in self.code:
                f.write(codeline.rstrip())
                f.write("\n")
            f.close()
            success = True

        except Exception, e:
            self.showError("Error trying to save the file.\n" + str(e))
        if success:
            try:
                os.remove(backupFilename)
            except Exception:
                pass
            try:
                oldstat = os.stat(filename)
                os.rename(filename, backupFilename)
                os.rename(tmpFilename, filename)
                os.chmod(filename, stat.S_IMODE(oldstat.st_mode)) # ensure permissions carried over
                self.filename = filename
                self.dirty = False
                print "Tasks saved."
            except Exception, e:
                self.showError("Error trying to rename the backups.\n" + str(e))

    def moveTo(self, indexStr):
        try:
            index = int(indexStr, 10)
            if index < 0 or index > len(self.todo) - 1:
                self.showError("Sorry but there is no task " + indexStr)
            else:
                if not self.isViewable(self.todo[index]):
                    print "Switching off your filter so that the task can be displayed."
                    self.clearFilterArray(False)
                self.currentTask = index
        except ValueError:
            self.showError("Unable to understand the task " + indexStr + " you want to show.")


    def moveToVisible(self):
        start = self.currentTask
        find = True
        if start < 0 or start >= len(self.todo):
            return
        while not self.isViewable(self.todo[self.currentTask]):
            self.incTaskLoop()
            if self.currentTask == start:
                print "Nothing matched your filter.  Removing your filter so that the current task can be displayed."
                self.clearFilterArray(False)
                break

    def decrypt(self, indexStr):
        index = self.getRequiredTask(indexStr)
        if index < 0 or index > len(self.todo) - 1:
            self.showError("Sorry but there is no task " + indexStr + " to show.")
        elif self.todo[index].hasHiddenTask():
            ec = Encryptor()
            print WordWrapper(gMaxLen).wrap(ec.enterKeyAndDecrypt(self.todo[index].getHiddenTask()))
        else:
            print "Task ", index, " has no encrypted data."

    def moveTask(self, indexStr, where):
        success = False
        if indexStr == "":
            print "You must supply the number of the task to move."
            return False
        try:
            index = self.getRequiredTask(indexStr)
            if index < 0 or index > len(self.todo) - 1:
                self.showError("Sorry but there is no task " + indexStr + " to move.")
            elif where == self.MOVE_DOWN:
                if index <= len(self.todo) - 2:
                    item = self.todo[index]
                    self.todo[index] = self.todo[index + 1]
                    self.todo[index + 1] = item
                    print "Task ", index, " moved down."
                    success = True
                else:
                    self.showError("Task " + str(index) + " is already at the bottom.")
            else:
                if index > 0:
                    if where == self.MOVE_TOP:
                        self.todo.insert(0, self.todo.pop(index))
                    else:
                        dest = index - 1
                        item = self.todo[dest]
                        self.todo[dest] = self.todo[index]
                        self.todo[index] = item
                    print "Task ", index, " moved up."
                    success = True
                else:
                    self.showError("Task " + str(index) + " is already at the top.")


        except ValueError:
            self.showError("Unable to understand the task " + indexStr + " you want to move.")

        return success

    def clear(self):
        cleared = False
        if safeRawInput("Are you really sure you want to remove everything? Yes or No? >>>").upper() != "YES":
            print("Nothing has been removed.")
        else:
            del self.todo[0:]
            self.currentTask = 0
            cleared = True
        return cleared

    def getRequiredTask(self, indexStr):
        if indexStr == "^" or indexStr.upper() == "THIS":
            index = self.currentTask
        else:
            try:
                index = int(indexStr, 10)
            except ValueError:
                index = -1
        return index

    def archiveTask(self, indexStr):
        doit = False
        line = indexStr.split(" ", 1)
        if len(line) > 1:
            indexStr = line[0]
            entry = line[1]
        else:
            entry = ""
        index = self.getRequiredTask(indexStr)
        if index < 0 or index > len(self.todo) - 1:
            self.showError("Sorry but there is no task " + indexStr + " to mark as done and archive.")
        else:
            if indexStr == "^" or indexStr.upper() == "THIS":
                doit = True
            else:
                print "Are you sure you want to archive: ' " + self.todo[index].toStringSimple() + "'"
                if safeRawInput("Enter Yes to archive this task? >>>").upper() == "YES":
                    doit = True
            if doit:
                newItem = self.createItem(":d+0")
                self.todo[index].copy(newItem, TodoItem.MODIFY)
                newItem = self.createItem(entry + " @Archived")
                self.todo[index].copy(newItem, TodoItem.APPEND)
                if self.writeArchive(self.todo[index]):
                    self.todo[index:index + 1] = []
                    print "Task ", index, " has been archived."
                else:
                    doit = False
                    print "Task ", index, " marked as archived but not removed."
            else:
                print "Task ", index, " has not been archived."
        return doit

    def removeTask(self, indexStr):
        doit = False
        index = self.getRequiredTask(indexStr)
        if index < 0 or index > len(self.todo) - 1:
            self.showError("Sorry but there is no task " + indexStr + " to delete.")
        else:
            if indexStr == "^" or indexStr.upper() == "THIS":
                doit = True
            else:
                print "Are you sure you want to remove ' " + self.todo[index].toStringSimple() + "'"
                if safeRawInput("Enter Yes to delete this task? >>>").upper() == "YES":
                    doit = True
            if doit:
                self.todo[index:index + 1] = []
                print "Task ", index, " has been removed."
            else:
                print "Task ", index, " has not been removed."
        return doit

    def substituteText(self, indexStr):
        line = indexStr.split(" ", 1)
        if len(line) > 1:
            indexStr = line[0]
            entry = line[1]
        else:
            self.showError("You need to define the task and substitution phrases. e.g SUB 0 /old/new/")
            return False


        success = False
        if indexStr == "":
            print "You must supply the number of the task to change."
            return False

        index = self.getRequiredTask(indexStr)

        if index < 0 or index > len(self.todo) - 1:
            self.showError("Sorry but there is no task " + indexStr)
        else:
            text = entry.replace("/", "\n")
            text = text.replace("\\\n","/")
            phrases = text.split("\n")
            if len(phrases) != 4:
                self.showError("The format of the command is incorrect.  The substitution phrases should be /s1/s2/ ")
                return False
            oldText = self.todo[index].getTask()
            newText = oldText.replace(phrases[1], phrases[2])
            if newText == oldText:
                self.showError("Nothing has changed.")
                return False
            newItem = self.createItem(newText)
            if newItem.hasError():
                print "With the substitution the task had errors:"
                print newItem.getError()
                print "Task ", index, " is unchanged."
            else:
                if newItem.hasHiddenTask():
                    clearScreen(self.sysCalls)
                    self.showError("It isn't possible to create private or secret data by using the substitition command.")
                else:
                    self.todo[index].copy(newItem, TodoItem.MODIFY)
                    print "Task ", index, " has been changed."
                    success = True
        return success


    def modifyTask(self, indexStr, replace, externalEditor = False):
        line = indexStr.split(" ", 1)
        if len(line) > 1:
            indexStr = line[0]
            entry = line[1]
        else:
            entry = ""

        success = False
        if indexStr == "":
            print "You must supply the number of the task to change."
            return

        index = self.getRequiredTask(indexStr)

        if index < 0 or index > len(self.todo) - 1:
            self.showError("Sorry but there is no task " + indexStr)
        else:
            if entry == "":
                if externalEditor:
                    exEdit = EditorLauncher()
                    (key, entry) = self.todo[index].toStringEditable()
                    entry = exEdit.edit(entry)
                else:
                    if replace == TodoItem.REPLACE:
                        print "This task will completely replace the existing entry,"
                        print "including any projects and actions."
                    elif replace == TodoItem.MODIFY:
                        print "Only the elements you add will be replaced.  So, for example,"
                        print "if you don't enter any projects the original projects will remain."
                    else:
                        print "Elements you enter will be appended to the current task"
                    entry = safeRawInput("Enter new details >>>")
            if entry != "":
                if replace == TodoItem.APPEND:
                    newItem = self.createItem(entry, password="unused") # we will discard the encrypted part on extend
                elif externalEditor:
                    newItem = self.createItem(entry, password = key)
                else:
                    newItem = self.createItem(entry)
                    if newItem.hasHiddenTask():
                        clearScreen(self.sysCalls)
                if newItem.hasError():
                    print "The task had errors:"
                    print newItem.getError()
                    print "Task ", index, " is unchanged."
                else:
                    if newItem.hasHiddenTask() and replace == TodoItem.APPEND:
                        self.showError("It isn't possible to extend the encrypted part of a task.\nThis part is ignored.")
                    self.todo[index].copy(newItem, replace)
                    print "Task ", index, " has been changed."
                    success = True
            else:
                print "Task ", index, " has not been touched."
        return success

    def incTask(self):
        if self.currentTask < len(self.todo) - 1:
            self.currentTask = self.currentTask + 1

    def incTaskLoop(self):
        if self.currentTask < len(self.todo) - 1:
            self.currentTask = self.currentTask + 1
        else:
            self.currentTask = 0
    def decTask(self):
        if self.currentTask > 0:
            self.currentTask = self.currentTask - 1

    def decTaskLoop(self):
        if self.currentTask > 0:
            self.currentTask = self.currentTask - 1
        else:
            self.currentTask = len(self.todo) - 1

    def printItemTruncated(self, index, leader):
        if len(self.todo) < 1:
            print leader, "no tasks"
        else:
            scrnline = leader + "[%02d] %s" % (index, self.todo[index].toStringSimple())
            if len(scrnline) > gMaxLen:
                print scrnline[0:gMaxLen - 3] + "..."
            else:
                print scrnline


    def printItem(self, index, colorType):
        if len(self.todo) < 1:
            self.output("There are no tasks to be done.\n", 0)
            nlines = 1
        else:
            wrapper = WordWrapper(gMaxLen)
            scrnline = wrapper.wrap("[%02d] %s" % (index, self.todo[index].toStringSimple()))
            if colorType == "row0":
                style = "class=\"evenTask\""
            else:
                style = "class=\"oddTask\""
            self.output("<div %s>[%02d] %s</div>\n" % (style, index, self.todo[index].toStringSimple()),
                    gColor.code(colorType) + scrnline + gColor.code("normal") + "\n" )
            nlines = wrapper.getNLines()
        return nlines

    def printItemVerbose(self, index):
        if len(self.todo) < 1:
            print "There are no tasks to be done."
        else:
            self.showFilter()
            wrapper = WordWrapper(gMaxLen)
            scrnline = wrapper.wrap("[%02d] %s" % (index, self.todo[index].toStringVerbose()))
            print scrnline

    def clearFilterArray(self, local):
        if local:
            self.localFilters = []
            self.localFilterText = ""
        else:
            self.globalFilters = []
            self.globalFilterText = ""

    def setFilterArray(self, local, requiredFilter):
        filters = requiredFilter.split()
        if local:
            destination = self.localFilters
        else:
            destination = self.globalFilters
        destination[:] = []
        humanVersion = ""
        for word in filters:
            if word[0:1] == "-":
                invert = True
                word = word[1:]
            else:
                invert = False
            if word[0:2].upper() == ":D" and len(word) > 2:
                filter = ":D" + TodoItem("").parseDate(word[2:].strip(), False)
            elif word[0:2].lower() == ":p":
                filter = globalPAbbr.expandProject(word)
            else:
                filter = globalAbbr.expandAction(word)
            if invert:
                filter = "-" + filter
            destination.append(filter)
            if humanVersion != "":
                humanVersion = humanVersion + " " + filter
            else:
                humanVersion = filter
        if local:
            for filter in self.globalFilters:
                destination.append(filter)
                if humanVersion != "":
                    humanVersion = humanVersion + " " + filter
                else:
                    humanVersion = filter
        if local:
            self.localFilterText = humanVersion
        else:
            self.globalFilterText = humanVersion

    def isViewable(self, item):
        if len(self.globalFilters) == 0 and len(self.localFilters) == 0:
            return True
        overallView = True
        ored = False
        if len(self.localFilters) > 0:
            filterArray = self.localFilters
        else:
            filterArray = self.globalFilters
        if "or" in filterArray or "OR" in filterArray:
            fast = False
        else:
            fast = True
        for filter in filterArray:
            if filter.upper() == "OR":
                ored = True
                continue
            view = False
            usePriority = False
            mustHave = False
            if filter[0:1] == "+":
                filter = filter[1:]
                mustHave = True
            if filter[0:1] == "-":
                invert = True
                filter = filter[1:]
            else:
                invert = False
            try:
                if filter[0:1] == "#":
                    priority = int(filter[1:], 10)
                    usePriority = True
            except ValueError:
                priority = 0
            if usePriority:
                if self.exactPriority:
                    if item.hasPriority(priority):
                        view = True
                elif item.hasPriorityOrAbove(priority):
                    view = True
            elif filter[0:2].upper() == ":D":
                if item.hasDate(filter[2:]):
                    view = True
            elif filter[0:2].upper() == ":P":
                view = item.hasProject(filter)
            elif filter[0:1].upper() == "@":
                view = item.hasAction(filter)
            elif item.hasWord(filter):
                view = True
            if invert:
                view = (view != True)
            if ored:
                if view == True:
                    overallView = True
                    break
            else:
                if view == False:
                    overallView = False
                    if fast or mustHave:
                        break
            ored = False
        return overallView

    def listByAction(self):
        index = SearchIndex()
        for item in self.todo:
            index.addCollection(item.getActions())
        index.sort()
        (n, value) = index.getFirstItem()
        print ruler
        self.showFilter()
        while n >= 0:
            if not gColor.usingColor() and n > 0:
                div = True
            else:
                div = False
            self.setFilterArray(True, "+" + value)
            self.printList(div, "<H2 class=\"hAction\">" + value + "</H2>\n", gColor.code("title") + "\n" + value + "\n" + gColor.code("title"))
            self.clearFilterArray(True)
            (n, value) = index.getNextItem(n)
        print ruler

    def listByProject(self):
        index = SearchIndex()
        for item in self.todo:
            index.addCollection(item.getProjects())
        index.sort()
        (n, value) = index.getFirstItem()
        print ruler
        self.showFilter()
        while n >= 0:
            if not gColor.usingColor() and n > 0:
                div = True
            else:
                div = False
            self.setFilterArray(True, "+:p" + value)
            self.printList(div, "<H2 class =\"hProject\">Project: " + value + "</H2>\n", gColor.code("title") + "\nProject: " + value + gColor.code("normal") + "\n")
            self.clearFilterArray(True)
            (n, value) = index.getNextItem(n)
        print ruler

    def listByDate(self):
        index = SearchIndex()
        for item in self.todo:
            index.add(item.getDate())
        index.sort()
        (n, value) = index.getFirstItem()
        print ruler
        self.showFilter()
        while n >= 0:
            if not gColor.usingColor() and n > 0:
                div = True
            else:
                div = False
            self.setFilterArray(True, "+:D" + value)
            self.printList(div, "<H2 class =\"hDate\">Date: " + value + "</H2>\n", gColor.code("title") + "\nDate: " + value + gColor.code("normal") + "\n")
            self.clearFilterArray(True)
            (n, value) = index.getNextItem(n)
        print ruler


    def showFilter(self):
        if self.globalFilterText != "":
            self.output("<H3 class =\"hFilter\">Filter = " + self.globalFilterText + "</H3>\n",
            gColor.code("bold") + "Filter = " + self.globalFilterText + gColor.code("normal") + "\n")

    def showLocalFilter(self):
        if self.localFilterText != "":
            self.output("<H3 class =\"hFilter\">Filter = " + self.localFilterText + "</H3>\n",
            gColor.code("bold") + "Filter = " + self.localFilterText + gColor.code("normal") + "\n")

    def printList(self, div, outHtml, outStd):
        self.doPrintList(-1, div, outHtml, outStd)

    def printShortList(self, line):
        count = 0
        try:
            count = int(line, 10)
        except ValueError:
            self.showError("Didn't understand the number of tasks you wanted listed.")
        self.doPrintList(count, False, "", "")

    def doPrintList(self, limitItems, div, outHtml, outStd):
        n = 0
        displayed = 0
        count = 0
        color = "row0"
        first = True
        maxlines = 20
        if outHtml != "":
            self.outputHtml("<div class=\"itemGroup\">\n")
        for item in self.todo:
            if self.isViewable(item):
                if first:
                    if div:
                        print divider
                    self.output(outHtml, outStd)
                if not gColor.usingColor() and not first:
                    print divider
                    count = count + 1
                count = count + self.printItem(n, color)
                first = False
                if color == "row0":
                    color = "row1"
                else:
                    color = "row0"
                displayed = displayed + 1
            n = n + 1
            if limitItems >= 0 and displayed >= limitItems:
                break
            if count >= maxlines:
                if self.htmlFile == "":
                    msg = safeRawInput("---press Enter for more.  Enter s to skip: ")
                    if len(msg) > 0 and msg.strip().upper()[0] == "S":
                        break;
                count = 0
        if outHtml != "":
            self.outputHtml("</div>\n")

    def printHelp(self, lines):
        ListViewer(24).show(lines,"!PAUSE!")

    def splitFile(self, filename, dataOnly):
        inData = False
        inCode = False
        inCfg = False
        f = open(filename, 'r')
        line = f.readline()
        if line[0:2] == "#!":
            line = f.readline()
        while line != "":
            if line.find(magicTag + "DATA") == 0:
                inData = True
                inCode = False
                inCfg = False
            elif line.find(magicTag + "CONFIG") == 0:
                inData = False
                inCode = False
                inCfg = True
            elif line.find(magicTag + "CODE") == 0:
                inCode = True
                inData = False
                inCfg = False
                if dataOnly:
                    break
            elif inCode:
                self.code.append(line)
            elif inCfg:
                self.processCfgLine(line)
            elif inData:
                line = line.strip()
                if len(line) > 0 and line[0] == "#":
                    line = line[1:].strip()
                if len(line) > 0:
                    newItem = self.createItem(line)
                    newItem.getError()
                    self.todo.append(newItem)

            line = f.readline()
        f.close()

    def createItem(self, line, password = ""):
        item = TodoItem(line, password)
        return item

    def outputHtml(self, html):
        if self.htmlFile != "":
            self.htmlFile.write(html)

    def output(self, html, stdout):
        if self.htmlFile != "":
            #self.htmlFile.write(html.replace("\n", "<br>\n"))
            self.htmlFile.write(html)
        if stdout == 0:
            print html,
        else:
            if stdout:
                print stdout,

    def startHtml(self, title):
        htmlFilename = self.filename + ".html"
        try:
            self.htmlFile = open(htmlFilename, "w")
            self.htmlFile.write("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n")
            self.htmlFile.write("<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n")
            self.htmlFile.write("<html>\n<head>\n")
            self.htmlFile.write("<style>\n")
            self.htmlFile.write(".footer {text-align:center;}\n")
            self.htmlFile.write("</style>\n")
            self.htmlFile.write("<link rel=\"stylesheet\" href=\"ikog.css\" type=\"text/css\">\n")
            self.htmlFile.write("</head>\n<body>\n")
            self.htmlFile.write("<div class=\"header\">\n")
            self.htmlFile.write("<H1 class=\"hTitle\">iKog Todo List</H1>\n")
            self.htmlFile.write("<H2 class=\"hSubTitle\">" + title + " printed " +  date.today().isoformat() + "</H1>\n")
            self.htmlFile.write("</div>\n")
            self.htmlFile.write("<div class=\"taskArea\">\n")
        except Exception:
            print "Failed to create output file:", htmlFilename
            self.htmlFile = ""

    def endHtml(self):
        name = self.htmlFile.name
        success = False
        try:
            self.htmlFile.write("</div>\n")
            self.htmlFile.write("<div class=\"footer\">\n")
            self.htmlFile.write("--- end of todo list ---<br>\n")
            self.htmlFile.write("Created using " + notice[0] + "\n<br>" + notice[1] + "<br>\n")
            self.htmlFile.write("</div>\n")

            self.htmlFile.write("</body>\n</html>\n")
            self.htmlFile.close()
            self.htmlFile = ""
            print "HTML file " + name + " created."
            success = True
        except Exception, e:
            self.showError("Error writing to file. " + str(e))

        if success:
            try:
                safeName = os.path.abspath(name).replace("\\","/")
                safeName = "file://" + urllib.quote(safeName," /:")
                webbrowser.open(safeName)
            except Exception, e:
                self.showError("Unable to launch html output. " + str(e))

class Abbreviations:
    def __init__(self, project = False):
        self.default(project)

    def default(self,project):
        if  project:
            self.abbrevs = {}
        else:
            self.abbrevs = {"@A":"@Anywhere","@C":"@Computer",
            "@D":"@Desk", "@E": "@Errands",
            "@H":"@Home", "@I":"@Internet","@L":"@Lunch", "@M":"@Meeting", "@N":"@Next",
            "@P":"@Phone", "@Pw":"@Password", "@S":"@Someday/Maybe",
            "@O":"@Other", "@W4":"@Waiting_For", "@W":"@Work"}


    def setAbbreviations(self, abbr):
        self.abbrevs.update(abbr)

    def addAbbreviation(self, key, word):
        self.abbrevs.update({key.title():word})

    def removeAbbreviation(self, key):
        key = key.title()
        if self.abbrevs.has_key(key):
            del self.abbrevs[key]
            return True
        return False

    def expandAction(self, action):
        if action[0:1] != "@":
            return action

        action = action.title()
        if self.abbrevs.has_key(action):
            return self.abbrevs[action]
        return action

    def expandProject(self, project):
        if not project.lower().startswith(":p"):
            return project
        project = project.title()
        if self.abbrevs.has_key(project):
            return self.abbrevs[project]
        return project

    def toString(self):
        return str(self.abbrevs)

    def toStringVerbose(self):
        output = ""
        index = 0
        for key in self.abbrevs:
            output = output + key.ljust(5) + " = " + self.abbrevs[key].ljust(30)
            index = index + 1
            if index % 2 == 0:
                output = output + "\n"
        if index % 2 != 0:
            output = output + "\n"
        return output

class SearchIndex:
    def __init__(self):
        self.items = []

    def add(self, ent):
        if ent != "" and not ent in self.items:
            self.items.append(ent)

    def addCollection(self, collection):
        for ent in collection:
            if ent != "" and not ent in self.items:
                self.items.append(ent)
    def sort(self):
        self.items.sort()

    def getFirstItem(self):
        if len(self.items) > 0:
            return (0, self.items[0])
        else:
            return (-1, "")

    def getNextItem(self, count):
        count = count + 1
        if count > len(self.items) - 1:
            return (-1, "")
        else:
            return (count, self.items[count])
            return

class  TodoItem:
    ENCRYPTION_MARKER = "{}--xx"
    REPLACE = 0
    MODIFY = 1
    APPEND = 2
    NOT_DUE_PRIORITY = 0
    DEFAULT_PRIORITY = 5
    OVERDUE_PRIORITY = 11
    MEETING_PRIORITY = 10
    def __init__(self,line, password = ""):
        self.actions = []
        self.task = ""
        self.hiddenTask = ""
        self.projects = []
        self.priority = -1
        self.when = ""
        self.created = date.today().isoformat()
        self.error = ""
        self.autoAction = False
        self.autoProject = False
        self.nullDate = False
        self.parse(line, password)

    def makeSafeDate(self, year, month, day):
        done = False
        while not done:
            if day < 1:
                done = True
            else:
                try:
                    newDate = date(year, month, day)
                    done = True
                except ValueError:
                    day = day - 1
                    newDate = ""
        return newDate

    def parseDate(self, dateStr, quiet):
        dateStr = dateStr.replace("/","-")
        dateStr = dateStr.replace(":","-")
        entry = dateStr.split("-")
        n = len(entry)
        if n < 1 or n > 3:
            fail = True
        elif dateStr == "0":
            self.nullDate = True
            return ""
        else:
            try:
                now = date.today()
                if dateStr[0:1] == "+":
                    days = int(dateStr[1:].strip(), 10)
                    when = now + timedelta(days)
                else:
                    if n == 3:
                        year = int(entry[0], 10)
                        month = int(entry[1], 10)
                        day = int(entry[2], 10)
                    elif n == 2:
                        year = now.year
                        month = int(entry[0], 10)
                        day = int(entry[1], 10)
                    else:
                        year = now.year
                        month = now.month
                        day = int(entry[0], 10)
                        if day < now.day:
                            month = month + 1
                        if month > 12:
                            month = 1
                            year = year + 1
                    if year < 1000:
                        year = year + 2000
                    when = self.makeSafeDate(year, month, day)
                fail = False
                self.nullDate = False
            except ValueError:
                fail = True
            except:
                fail = True
        if fail:
            self.addError("Could not decode the date. Use :dYYYY/MM/DD")
            return ""
        else:
            return when.isoformat()

    def parse(self, line, password):
        self.error = ""
        words = line.split(" ")
        taskToHide = ""
        encrypt = ""
        start = 0
        ecmLen = len(self.ENCRYPTION_MARKER)
        for word in words[start:]:
            wordUC = word.strip().upper()
            if len(word) > 0:
                if encrypt != "":
                    taskToHide = taskToHide + word.strip() + " "
                elif word[0:ecmLen] == self.ENCRYPTION_MARKER:
                    self.hiddenTask = word[ecmLen:]
                elif wordUC.startswith("<PRIVATE>") or wordUC.startswith("<SECRET>") or wordUC.startswith("<S>") or wordUC.startswith("<P>"):
                    encrypt = wordUC[1]
                    try:
                        pos = word.index(">")
                        taskToHide = taskToHide + word[pos + 1:].strip() + " "
                    except ValueError:
                        pass
                elif word[0] == "@" and len(word) > 1:
                    if wordUC == "@DATE":
                        self.addError("@Date contexts should not be entered. Use :dYYYY-MM-DD")
                    else:
                        act = globalAbbr.expandAction(word.strip())
                        if not act in self.actions:
                            self.actions.append(act)
                elif word[0:1] == "#" and len(word) > 1 and self.priority == -1:
                    try:
                        self.priority = int(word[1:].strip(), 10)
                        if self.priority < 1:
                            self.priority = 0
                        elif self.priority > 10:
                            self.priority = 10
                    except ValueError:
                        self.addError("Did not understand priority.")
                        self.priority = -1
                elif wordUC[0:2] == ":P" and len(word) > 2:
                    proj = globalPAbbr.expandProject(word.strip())[2:].title()
                    if not proj in self.projects:
                        self.projects.append(proj)
                elif wordUC[0:8] == ":CREATED" and len(word) > 8:
                    self.created = word[8:].strip()
                elif wordUC[0:2] == ":D" and len(word) > 2:
                    self.when = self.parseDate(word[2:].strip(), False)
                else:
                    self.task = self.task + word.strip() + " "
        if taskToHide != "":
            ec = Encryptor()
            if encrypt == "S":
                if ec.setType(ec.TYPE_AES) != ec.TYPE_AES:
                    self.addError("AES encryption is not available.")
                    taskToHide = ""
            else:
                ec.setType(ec.TYPE_OBSCURED)
        if taskToHide != "":
            if password == "":
                self.hiddenTask = ec.enterKeyAndEncrypt(taskToHide)
            else:
                ec.setKey(password)
                self.hiddenTask = ec.encrypt(taskToHide)

        if len(self.actions) == 0:
            self.actions.append("@Anywhere")
	    self.autoAction = True
        if len(self.projects) == 0:
            self.projects.append("None")
	    self.autoProject = True

    def addError(self, err):
        if len(self.error) > 0:
            self.error = self.error + "\n"
        self.error = self.error + err

    def hasError(self):
        return self.error != ""

    def getError(self):
        tmp = self.error
        self.error = ""
        return tmp

    def hasWord(self, word):
        return (self.task.upper().find(word.upper()) >= 0)

    def hasAction(self, loc):
        if self.when != "" and loc.upper() == "@DATE":
            return True
        else:
            return loc.title() in self.actions

    def copy(self, todoItem, replace):
        if replace == TodoItem.REPLACE or len(todoItem.task.strip()) > 0:
            if replace == TodoItem.APPEND:
                self.task = self.task + " ..." + todoItem.task
            else:
                self.task = todoItem.task
        if replace == TodoItem.REPLACE or todoItem.autoAction == False:
            if replace != TodoItem.APPEND:
                self.actions = []
            for loc in todoItem.actions:
                if not loc in self.actions:
                    self.actions.append(loc)
        if replace == TodoItem.REPLACE or todoItem.autoProject == False:
            if replace != TodoItem.APPEND:
                self.projects = []
            for proj in todoItem.projects:
                if not proj in self.projects:
                    self.projects.append(proj)
        if replace == TodoItem.REPLACE or (todoItem.when != "" or todoItem.nullDate == True):
            self.when = todoItem.when
        if todoItem.priority >= 0:
            self.priority = todoItem.priority

        if replace == TodoItem.REPLACE or len(todoItem.hiddenTask.strip()) > 0:
            if replace == TodoItem.APPEND:
                pass
            else:
                self.hiddenTask = todoItem.hiddenTask

    def hasHiddenTask(self):
        return self.hiddenTask != ""

    def hasTask(self):
        return len(self.task.strip()) > 0

    def hasProject(self, proj):
        if proj[0:2].upper() == ":P":
            proj = proj[2:]
        return proj.title() in self.projects

    def hasDate(self, dt):
        dt = self.parseDate(dt, True)
        if dt == "":
            return False
        else:
            return self.when == dt

    def hasPriorityOrAbove(self, priority):
        return (self.getEffectivePriority() >= priority)

    def hasPriority(self, priority):
        return (self.getEffectivePriority() == priority)

    def getHiddenTask(self):
        return self.hiddenTask

    def getTask(self):
        return self.task

    def getActions(self):
        if self.when == "":
            return self.actions
        else:
            return self.actions + ["@Date"]

    def getProjects(self):
        return self.projects

    def getDate(self):
        return self.when

    def getPriority(self):
        if self.priority < 0:
            return self.DEFAULT_PRIORITY
        else:
            return self.priority

    def getEffectivePriority(self):
        userP = self.getPriority()
        if self.when != "":
            if self.when <= date.today().isoformat():
                userP = self.OVERDUE_PRIORITY + userP
                if self.hasAction("@Meeting"):
                    userP = userP + self.MEETING_PRIORITY
            else:
                userP = self.NOT_DUE_PRIORITY
        return userP


    def toString(self):
        entry = "#"
        entry = entry + " " + self.task
        for action in self.actions:
            entry = entry + " " + action
        for project in self.projects:
            entry = entry + " :p" + project
        entry = entry + " :created" + self.created
        if self.when != "":
            entry = entry + " :d" + self.when
        if self.priority >= 0:
            entry = entry + " #" + str(self.priority)
        if self.hiddenTask != "":
            entry = entry + " " + self.ENCRYPTION_MARKER + self.hiddenTask
        return entry

    def toStringEditable(self, includeHidden = False):
        password = ""
        entry = ""
        if self.when != "":
            entry = entry + ":d" + self.when + " "
        entry = entry + "%s #%d" % (self.task, self.getPriority())
        if len(self.actions) > 0:
            for action in self.actions:
                entry = entry + " " + action
        if len(self.projects) > 0:
            for project in self.projects:
                # skip the none tag
                if project != "None":
                    entry = entry + " :p" + project
        if self.hiddenTask != "" and includeHidden:
            ec = Encryptor()
            entry = entry + " <" + Encryptor().getSecurityClass(self.hiddenTask)[0:1] + ">"
            entry = entry + ec.enterKeyAndDecrypt(self.hiddenTask)
            password = ec.getKey()
        return (password, entry.strip())

    def toStringSimple(self):
        entry = ""
        if self.when != "":
            entry = entry + "@Date " + self.when + " "
        entry = entry + "%s #%d" % (self.task, self.getPriority())
        if self.hiddenTask != "":
            entry = entry + " <*** " + Encryptor().getSecurityClass(self.hiddenTask) + " ***> "
        if len(self.actions) > 0:
            for action in self.actions:
                entry = entry + " " + action
        if len(self.projects) > 0:
            first = True
            for project in self.projects:
                # skip the none tag
                if project != "None":
                    if first:
                        entry = entry + " Projects: " + project
                        first = False
                    else:
                        entry = entry + ", " + project
        #entry = entry + " [" + self.created + "]"
        return entry

    def toStringVerbose(self):
        entry = gColor.code("title") + self.task
        if self.hiddenTask != "":
            entry = entry + " <*** " + Encryptor().getSecurityClass(self.hiddenTask) + " ***> "
        entry = entry + gColor.code("bold") + "\nPriority: %02d" % (self.getPriority())
        if len(self.actions) or self.when != "" > 0:
            entry = entry + gColor.code("heading") + "\nContext: "
            if self.when != "":
                entry = entry + gColor.code("important") + "@Date " + self.when
            entry = entry + gColor.code("normal")
            for action in self.actions:
                entry = entry + " " + action;
        if len(self.projects) > 0:
            first = True
            for project in self.projects:
                if project != "None":
                    if first:
                        entry = entry + gColor.code("heading") + "\nProjects: " + gColor.code("normal");
                        entry = entry + project
                        first = False
                    else:
                        entry = entry + ", " + project
        entry = entry + gColor.code("normal") + "\nCreated: [" + self.created + "]"
        return entry

# signal.signal(signal.SIGINT, signalHandler)
gColor = ColorCoder(cfgColor)
globalAbbr = Abbreviations()
globalPAbbr = Abbreviations(project=True)
commandList = []
if len(sys.argv) > 2:
    command = ""
    reopen = sys.argv[1]
    if reopen == ".":
        reopen = sys.argv[0] + ".dat"
    for word in sys.argv[2:]:
        if word == "/":
            commandList.append(command)
            command = ""
        else:
            command = command + word + " "
    commandList.append(command)
elif len(sys.argv) > 1:
    reopen = sys.argv[1]
else:
    reopen = sys.argv[0] + ".dat"
while reopen != "":
    #print commandList
    todoList = TodoList(sys.argv[0], reopen)
    reopen = todoList.run(commandList)
    commandList = []

