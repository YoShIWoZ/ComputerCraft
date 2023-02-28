local mon = peripheral.wrap("right");
local modem = peripheral.wrap("back");
local monW, monH = mon.getSize();
local backgroundImage = paintutils.loadImage("background.nfp");
local startPressed = false;
local lightsOpen = false;
local lightsDrawn = false;
local lightsMaximized = false;
local powerOpen = false;
local powerDrawn = false;
local powerMaximized = false;
local focus = "";
local osColor = colors.gray;
local osBackgroundColor = colors.lightGray;
local osStartMenuColor = colors.white;
local maxEnergy = 0;
local currentEnergy = 0;
local energyInput = 0;
local energyOutput = 0;
local maxTransfer = 0;
local numProviders = 0;
local numCells = 0;

-- Modem
for i = 1, 17 do
    modem.open(i);
end

-- Lights
local area1State = "On";
local area2State = "On";
local area3State = "On";
local area4State = "On";
local area5State = "On";
local area6State = "On";
local area7State = "On";
local area8State = "On";
local area9State = "On";
local area10State = "On";

mon.clear();
mon.setCursorPos(1,1);
mon.setTextScale(1);

-- Function to get methods printed to terminal or monitor (boolean)
local function getMethods(direction, printToMonitor)
    local i = 1;
    for _,v in pairs(peripheral.getMethods(direction)) do
        if not v:find("Colour") then
            print(v);
            if (printToMonitor) then
                mon.write(v);
                mon.setCursorPos(1,i);
            end
            i = i + 1;
        end
    end
end
-- Function to write to the monitor
local function writeToMon(x, y, bgColor, textColor, text)
    mon.setCursorPos(x,y);
    mon.setBackgroundColor(bgColor);
    mon.setTextColor(textColor);
    mon.write(text);
end

-- Function to set the background color
local function drawDesktop(color)
    mon.setBackgroundColor(color);
    for h = 1, monH - 1 do
        for w = 1, monW do
            mon.setCursorPos(w, h);
            mon.write(" ");
        end
    end
    local oldTerm = term.redirect(mon);
    paintutils.drawImage(backgroundImage, 1, 1);
    term.redirect(oldTerm);
end

-- Function to set background color for software
local function setProgramBackgroundColor(color)
    mon.setBackgroundColor(color);
    for h = 2, monH - 1 do
        for w = 1, monW do
            mon.setCursorPos(w, h);
            mon.write(" ");
        end
    end
end

-- Clock (Needs to be in co-routine)
local function clock()
    while true do
        local time = textutils.formatTime(os.time(), true);
        writeToMon(monW - 4, monH, osColor, colors.black, "    ");
        writeToMon(monW - string.len(time) +1, monH, osColor, colors.white, time);
        sleep(.8);
    end
end
-- Background
drawDesktop(osBackgroundColor);

-- Start Menu
writeToMon(1, monH, colors.green, colors.black, "Start");
for w = 6, monW do
    mon.setBackgroundColor(osColor);
    mon.setCursorPos(w, monH);
    mon.write(" ");
end

local function closeAllPrograms()
    startPressed = false;
    lightsOpen = false;
end

local function drawButton(x, y, state, name)
    writeToMon(x + (11/2 - string.len(name)/2), y - 1, osBackgroundColor, colors.black, name);
    if state == "On" then
        writeToMon(x, y,   colors.green, colors.black, "           ");
        writeToMon(x, y+1, colors.green, colors.black, "    ON     ");
        writeToMon(x, y+2, colors.green, colors.black, "           ");
    else
        writeToMon(x, y,   colors.red, colors.white, "           ");
        writeToMon(x, y+1, colors.red, colors.white, "    OFF    ");
        writeToMon(x, y+2, colors.red, colors.white, "           ");
    end
end

local function drawTouchButton(x, y, state, name, programOpen)
    -- Hallway Button (Touch)
    if MonX >= x and MonX <= x+10 and MonY >= y and MonY <= y+2 and programOpen then
        if (state == "On") then
            drawButton(x, y, "Off", name);
            return "Off";
        else
            drawButton(x, y, "On", name);
            return "On";
        end
    else
        return state;
    end
end
local function drawLights()
    local programName = "Light Control"
    -- Start menu control
    focus = "lights";
    startPressed = false;
    lightsOpen = true;
    lightsMaximized = true;
    powerMaximized = false;
    drawDesktop(osBackgroundColor);
    -- Lights Software Top Bar
    mon.setCursorPos(1, 1);
    mon.setBackgroundColor(osColor);
    mon.setTextColor(colors.white);
    for i = 1, monW do
        mon.write(" ");
    end
    mon.setCursorPos(1, 1);
    for i = 1, monW/2 - string.len(programName)/2 do
        mon.write(" ");
    end
    mon.write(programName);
    mon.setCursorPos(monW,1);
    mon.setBackgroundColor(colors.red);
    mon.setTextColor(colors.black);
    mon.write("X");
    setProgramBackgroundColor(osBackgroundColor);
    -- Lights Software Buttons
    -- Lights Software Hallway Button
    drawButton(2, 4, area1State, "Hallway");
    -- Lights Software AE Button
    drawButton(14, 4, area2State, "AE2");
    -- Lights Software Control Button
    drawButton(27, 4, area3State, "Control");
    -- Lights Software Portals Button
    drawButton(39, 4, area4State, "Portals");
    -- Lights Software Smelter Button
    drawButton(2, 9, area5State, "Smelter");
    -- Lights Software Botania Button
    drawButton(14, 9, area6State, "Botania");
    -- Lights Software Fishers Button
    drawButton(27, 9, area7State, "Fishers");
    -- Lights Software Botany Pots Button
    drawButton(39, 9, area8State, "Botany Pots");
    -- Lights Software Farms Button
    drawButton(2, 14, area9State, "Farms");
    -- Lights Software Factories Button
    drawButton(14, 14, area10State, "Factories");
end
local function drawPower()
    local programName = "Power Control"
    -- Start menu control
    focus = "power";
    startPressed = false;
    powerOpen = true;
    powerMaximized = true;
    lightsMaximized = false;
    drawDesktop(osBackgroundColor);
    -- Lights Software Top Bar
    mon.setCursorPos(1, 1);
    mon.setBackgroundColor(osColor);
    mon.setTextColor(colors.white);
    for i = 1, monW do
        mon.write(" ");
    end
    mon.setCursorPos(1, 1);
    for i = 1, monW/2 - string.len(programName)/2 do
        mon.write(" ");
    end
    mon.write(programName);
    mon.setCursorPos(monW,1);
    mon.setBackgroundColor(colors.red);
    mon.setTextColor(colors.black);
    mon.write("X");
    setProgramBackgroundColor(osBackgroundColor);
    -- Power Software Fields
    for w = 2, 21 do
        for h = 3, 15 do
            writeToMon(w, h, colors.white, colors.black, " ");
        end
    end
    for w = 2, 21 do
        writeToMon(w, 3, colors.blue, colors.black, " ");
    end 
    local powerBankName = "Bank 1";
    writeToMon(2 + 21/2 - string.len(powerBankName)/2, 3, colors.blue, colors.white, powerBankName);
end
local function lights()
    if (MonX >= 1 and MonX <= 10 and MonY == monH - 8 and startPressed) or (lightsOpen and not startPressed and MonX > 0 and MonX < 6 and MonY == monH and lightsMaximized) then
        drawLights();
    end
    if lightsDrawn and focus == "lights" then
        -- Close Button (Touch)
        if MonX == monW and MonY == 1 and lightsOpen then
            lightsOpen = false;
            lightsDrawn = false;
            lightsMaximized = false;
            drawDesktop(osBackgroundColor);
        end
        -- Hallway Button (Touch)
        area1State = drawTouchButton(2, 4, area1State, "Hallway", lightsOpen);
        modem.transmit(1, 1, area1State);
        -- AE2 Button (Touch)
        area2State = drawTouchButton(14, 4, area2State, "AE2", lightsOpen);
        modem.transmit(2, 2, area2State);
        -- Control Button (Touch)
        area3State = drawTouchButton(27, 4, area3State, "Control", lightsOpen);
        modem.transmit(3, 3, area3State);
        -- Portals Button (Touch)
        area4State = drawTouchButton(39, 4, area4State, "Portals", lightsOpen);
        modem.transmit(4, 4, area4State);
        -- Smelter Button (Touch)
        area5State = drawTouchButton(2, 9, area5State, "Smelter", lightsOpen);
        modem.transmit(5, 5, area5State);
        -- Botania Button (Touch)
        area6State = drawTouchButton(14, 9, area6State, "Botania", lightsOpen);
        modem.transmit(6, 6, area6State);
        -- Fishers Button (Touch)
        area7State = drawTouchButton(27, 9, area7State, "Fishers", lightsOpen);
        modem.transmit(7, 7, area7State);
        -- Botany Pots Button (Touch)
        area8State = drawTouchButton(39, 9, area8State, "Botany Pots", lightsOpen);
        modem.transmit(8, 8, area8State);
        -- Farms Button (Touch)
        area9State = drawTouchButton(2, 14, area9State, "Farms", lightsOpen);
        modem.transmit(9, 9, area9State);
        -- Factories Button (Touch)
        area10State = drawTouchButton(14, 14, area10State, "Factories", lightsOpen);
        modem.transmit(10, 10, area10State);
    end
end
local function power()
    if (MonX >= 1 and MonX <= 10 and MonY == monH - 7 and startPressed) or (powerOpen and not startPressed and MonX > 0 and MonX < 7 and MonY == monH and powerMaximized) then
        drawPower();
    end
    if powerDrawn and focus == "power" then
        -- Close Button (Touch)
        if MonX == monW and MonY == 1 and powerOpen then
            powerOpen = false;
            powerDrawn = false;
            powerMaximized = false;
            drawDesktop(osBackgroundColor);
        end
    end
end

local function drawTask(x, name)
    writeToMon(x, monH, colors.brown, colors.white, " " .. name .. " ");
end
local function  taskbar()
    local x = 6
    for w = 6, monW - 5 do
        mon.setBackgroundColor(osColor);
        mon.setCursorPos(w, monH);
        mon.write(" ");
    end
    if lightsOpen then
        local name = "Lights";
        drawTask(x, name);
        if MonX >= x and MonX < x + string.len(name) + 2 and MonY == monH then
            if lightsMaximized then
                lightsMaximized = false;
                lightsDrawn = false;
                drawDesktop(osBackgroundColor);
            else
                powerMaximized = false;
                drawLights();
                lightsDrawn = true;
                focus = "lights";
            end
        end
        x = x + string.len(name) + 3;
    end
    if powerOpen then
        local name = "Power";
        drawTask(x, name)
        if MonX >= x and MonX < x + string.len(name) + 2 and MonY == monH then
            if powerMaximized then
                powerMaximized = false;
                powerDrawn = false;
                drawDesktop(osBackgroundColor);
            else
                lightsMaximized = false;
                drawPower();
                powerDrawn = true;
                focus = "power";
            end
        end
        x = x + string.len(name) + 3;
    end
end

local function startButton()
    if MonX > 0 and MonX < 6 and MonY == monH then
        if not startPressed then
            mon.setBackgroundColor(osStartMenuColor);
            mon.setTextColor(colors.black);
            for i = 1, 8 do
                for w = 1, 10 do
                    mon.setCursorPos(w, monH - i);
                    mon.write(" ");
                end
            end
            mon.setCursorPos(1, monH - 2);
            mon.write("Restart");
            mon.setCursorPos(1, monH - 3);
            mon.write("Shut down");
            mon.setCursorPos(1, monH - 1);
            mon.write("Programs >");
            mon.setCursorPos(1, monH - 8);
            mon.write("Lights");
            mon.setCursorPos(1, monH - 7);
            mon.write("Power");
            --closeAllPrograms();
            startPressed = true;
            lightsDrawn = false;
            powerDrawn = false;
        else
            if lightsOpen and lightsMaximized then
                lights();
            elseif powerOpen and powerMaximized then
                power();
            else
                drawDesktop(osBackgroundColor);
            end
            startPressed = false;
        end
    end
end

local function touch ()
    while true do
        _, _, MonX, MonY = os.pullEvent("monitor_touch")
        -- Start Button
        startButton();
        if MonX >= 1 and MonX <= 10 and MonY == monH - 3 and startPressed then
            mon.setBackgroundColor(colors.black);
            mon.clear();
            os.shutdown();
        end
        if MonX >= 1 and MonX <= 10 and MonY == monH - 2 and startPressed then
            mon.setBackgroundColor(colors.black);
            mon.clear();
            writeToMon(monW/2 - 5, monH/2,colors.black, colors.white, "Rebooting!");
            os.reboot();
        end
        lights();
        power();
        if lightsOpen and not startPressed and lightsMaximized then
            lightsDrawn = true;
        end
        if powerOpen and not startPressed and powerMaximized then
            powerDrawn = true;
        end
        -- Taskbar
        taskbar();
    end
end
local function getData ()
    local shortMaxEnergy = 0;
    local shortMaxEnergyUnit = "";
    local shortCurEnergy = 0;
    local shortCurEnergyUnit = "";
    local shortEnergyInput = 0;
    local shortEnergyInputUnit = "";
    local shortEnergyOutput = 0;
    local shortEnergyOutputUnit = "";
    local averageEnergyOutput = 0;
    local shortAverageEnergyOutput = 0;
    local shortAverageEnergyOutputUnit = "";
    local shortMaxTransfer = 0;
    local shortMaxTransferUnit = "";
    local energyTable = {}
    local timer = 0;
    local function average(table)
        local sum = 0
        for i = 1, #table do
            sum = sum + table[i]
        end
        return sum/#table
    end

    while true do
        local _, _, frequency, _, message, _ = os.pullEvent("modem_message");
        if frequency == 11 then
            maxEnergy = message;
        end
        if frequency == 12 then
            currentEnergy = message;
        end
        if frequency == 13 then
            energyInput = message;
        end
        if frequency == 14 then
            energyOutput = message;
        end
        if frequency == 15 then
            maxTransfer = message;
        end
        if frequency == 16 then
            numProviders = message;
        end
        if frequency == 17 then
            numCells = message;
        end
        if averageEnergyOutput == 0 then
            averageEnergyOutput = energyOutput;
        end
        timer = timer + 1 / 10
        if timer > 60 then
            timer = 0;
            averageEnergyOutput = average(energyTable);
            energyTable = {}
        end
        table.insert(energyTable, energyOutput)
        if powerOpen and powerDrawn and powerMaximized then
            writeToMon(3, 5, colors.lightGray, colors.black, "             "); writeToMon(20 - string.len(math.floor(currentEnergy/maxEnergy * 100)), 5, colors.white, colors.black, math.floor(currentEnergy/maxEnergy * 100) .. "%");
            if currentEnergy/maxEnergy * 100 > 98 then
                writeToMon(3, 5, colors.green, colors.black, "             ");
            elseif currentEnergy/maxEnergy * 100 > 95 then
                writeToMon(3, 5, colors.green, colors.black, "            ");
            elseif currentEnergy/maxEnergy * 100 > 90 then
                writeToMon(3, 5, colors.green, colors.black, "           ");
            elseif currentEnergy/maxEnergy * 100 > 80 then
                writeToMon(3, 5, colors.green, colors.black, "          ");
            elseif currentEnergy/maxEnergy * 100 > 75 then
                writeToMon(3, 5, colors.green, colors.black, "         ");
            elseif currentEnergy/maxEnergy * 100 > 70 then
                writeToMon(3, 5, colors.green, colors.black, "        ");
            elseif currentEnergy/maxEnergy * 100 > 60 then
                writeToMon(3, 5, colors.green, colors.black, "       ");
            elseif currentEnergy/maxEnergy * 100 > 50 then
                writeToMon(3, 5, colors.green, colors.black, "      ");
            elseif currentEnergy/maxEnergy * 100 > 40 then
                writeToMon(3, 5, colors.green, colors.black, "     ");
            elseif currentEnergy/maxEnergy * 100 > 30 then
                writeToMon(3, 5, colors.green, colors.black, "    ");
            elseif currentEnergy/maxEnergy * 100 > 20 then
                writeToMon(3, 5, colors.green, colors.black, "   ");
            elseif currentEnergy/maxEnergy * 100 > 10 then
                writeToMon(3, 5, colors.green, colors.black, "  ");
            elseif currentEnergy/maxEnergy * 100 > 0 then
                writeToMon(3, 5, colors.green, colors.black, " ");
            elseif currentEnergy/maxEnergy * 100 == 0 then
                writeToMon(3, 5, colors.green, colors.black, "");
            end
            -- Bank width: 19
            if maxEnergy > 1000000000000 then
                shortMaxEnergy = maxEnergy/1000000000000
                shortMaxEnergyUnit = "T";
            elseif maxEnergy > 1000000000 then
                shortMaxEnergy = maxEnergy/1000000000
                shortMaxEnergyUnit = "G";
            elseif maxEnergy > 1000000 then
                shortMaxEnergy = maxEnergy/1000000;
                shortMaxEnergyUnit = "M";
            elseif maxEnergy > 1000 then
                shortMaxEnergy = maxEnergy/1000;
                shortMaxEnergyUnit = "K";
            elseif maxEnergy < 1000 then
                shortMaxEnergy = maxEnergy;
                shortMaxEnergyUnit = "";
            end
            if currentEnergy > 1000000000000 then
                shortCurEnergy = string.sub(currentEnergy/1000000000000, 1, 4);
                shortCurEnergyUnit = "T";
            elseif currentEnergy > 1000000000 then
                shortCurEnergy = string.sub(currentEnergy/1000000000, 1, 4);
                shortCurEnergyUnit = "G";
            elseif currentEnergy > 1000000 then
                shortCurEnergy = string.sub(currentEnergy/1000000, 1, 4);
                shortCurEnergyUnit = "M";
            elseif currentEnergy > 1000 then
                shortCurEnergy = string.sub(currentEnergy/1000, 1, 4);
                shortCurEnergyUnit = "K";
            elseif currentEnergy < 1000 then
                shortCurEnergy = currentEnergy;
                shortCurEnergyUnit = "";
            end
            if energyInput > 1000000000000 then
                shortEnergyInput = string.sub(energyInput/1000000000000, 1, 3);
                shortEnergyInputUnit = "T";
            elseif energyInput > 1000000000 then
                shortEnergyInput = string.sub(energyInput/1000000000, 1, 4);
                shortEnergyInputUnit = "G";
            elseif energyInput > 1000000 then
                shortEnergyInput = string.sub(energyInput/1000000, 1, 4);
                shortEnergyInputUnit = "M";
            elseif energyInput > 1000 then
                shortEnergyInput = math.floor(energyInput/1000);
                shortEnergyInputUnit = "K";
            elseif energyInput < 1000 then
                shortEnergyInput = energyInput;
                shortEnergyInputUnit = "";
            end
            if energyOutput > 1000000000000 then
                shortEnergyOutput = math.floor(energyOutput/1000000000000);
                shortEnergyOutputUnit = "T";
            elseif energyOutput > 1000000000 then
                shortEnergyOutput = math.floor(energyOutput/1000000000);
                shortEnergyOutputUnit = "G";
            elseif energyOutput > 1000000 then
                shortEnergyOutput = math.floor(energyOutput/1000000);
                shortEnergyOutputUnit = "M";
            elseif energyOutput > 1000 then
                shortEnergyOutput = math.floor(energyOutput/1000);
                shortEnergyOutputUnit = "K";
            elseif energyOutput < 1000 then
                shortEnergyOutput = energyOutput;
                shortEnergyOutputUnit = "";
            end
            if averageEnergyOutput > 1000000000000 then
                shortAverageEnergyOutput = math.floor(averageEnergyOutput/1000000000000);
                shortAverageEnergyOutputUnit = "T";
            elseif averageEnergyOutput > 1000000000 then
                shortAverageEnergyOutput = math.floor(averageEnergyOutput/1000000000);
                shortAverageEnergyOutputUnit = "G";
            elseif averageEnergyOutput > 1000000 then
                shortAverageEnergyOutput = math.floor(averageEnergyOutput/1000000);
                shortAverageEnergyOutputUnit = "M";
            elseif averageEnergyOutput > 1000 then
                shortAverageEnergyOutput = math.floor(averageEnergyOutput/1000);
                shortAverageEnergyOutputUnit = "K";
            elseif averageEnergyOutput < 1000 then
                shortAverageEnergyOutput = averageEnergyOutput;
                shortAverageEnergyOutputUnit = "";
            end
            if maxTransfer > 1000000000000 then
                shortMaxTransfer = math.floor(maxTransfer/1000000000000);
                shortMaxTransferUnit = "T";
            elseif maxTransfer > 1000000000 then
                shortMaxTransfer = math.floor(maxTransfer/1000000000);
                shortMaxTransferUnit = "G";
            elseif maxTransfer > 1000000 then
                shortMaxTransfer = string.sub(maxTransfer/1000000, 1, 4);
                shortMaxTransferUnit = "M";
            elseif maxTransfer > 1000 then
                shortMaxTransfer = math.floor(maxTransfer/1000);
                shortMaxTransferUnit = "K";
            elseif maxTransfer < 1000 then
                shortMaxTransfer = maxTransfer;
                shortMaxTransferUnit = "";
            end

            writeToMon(3, 7, colors.white, colors.black, "                ");
            writeToMon(3, 7, colors.white, colors.black, "Max FE:"); writeToMon(21 - string.len(shortMaxEnergy) - string.len(shortMaxEnergyUnit), 7, colors.white, colors.black, shortMaxEnergy .. shortMaxEnergyUnit);
            writeToMon(3, 8, colors.white, colors.black, "                ");
            writeToMon(3, 8, colors.white, colors.black, "Current FE:"); writeToMon(21 - string.len(shortCurEnergy) - string.len(shortCurEnergyUnit), 8, colors.white, colors.black, shortCurEnergy .. shortCurEnergyUnit);
            writeToMon(3, 9, colors.white, colors.black, "                ");
            writeToMon(3, 9, colors.white, colors.black, "FE Input:"); writeToMon(21 - string.len(shortEnergyInput) - string.len(shortEnergyInputUnit), 9, colors.white, colors.black, shortEnergyInput .. shortEnergyInputUnit);
            writeToMon(3, 10, colors.white, colors.black, "                ");
            writeToMon(3, 10, colors.white, colors.black, "FE Output:"); writeToMon(21 - string.len(shortEnergyOutput) - string.len(shortEnergyOutputUnit), 10, colors.white, colors.black, shortEnergyOutput .. shortEnergyOutputUnit);
            writeToMon(3, 11, colors.white, colors.black, "                ");
            writeToMon(3, 11, colors.white, colors.black, "Avg. Output:"); writeToMon(21 - string.len(shortAverageEnergyOutput) - string.len(shortAverageEnergyOutputUnit), 11, colors.white, colors.black, shortAverageEnergyOutput .. shortAverageEnergyOutputUnit);
            writeToMon(3, 12, colors.white, colors.black, "                ");  
            writeToMon(3, 12, colors.white, colors.black, "Max Output:"); writeToMon(21 - string.len(shortMaxTransfer) - string.len(shortMaxTransferUnit), 12, colors.white, colors.black, shortMaxTransfer .. shortMaxTransferUnit);
            writeToMon(3, 13, colors.white, colors.black, "                ");
            writeToMon(3, 13, colors.white, colors.black, "Providers:"); writeToMon(21 - string.len(numProviders), 13, colors.white, colors.black, string.sub(numProviders, 1, 1));
            writeToMon(3, 14, colors.white, colors.black, "                ");
            writeToMon(3, 14, colors.white, colors.black, "Cells:") writeToMon(21 - string.len(numCells), 14, colors.white, colors.black, string.sub(numCells,1, 1));
        end
    end
    sleep(0.1)
end
-- Parallel, start co-routine clock and touch
parallel.waitForAny(clock, touch, getData);
