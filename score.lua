table.copy = function(t)
    r = {}
    for n,v in pairs(t) do
        r[n] = v
    end
    return r
end

math.randomseed(os.time())

local strike = {"unique identifier"}

local function calculate(sheet)
    local score = 0
    local bonus = {}

    local flat = {}
    for i,pair in ipairs(sheet) do
        if pair ~= strike and type(pair) ~= 'number' then
            for q=1,#pair do
                flat[#flat+1] = pair[q]
            end
        else
            flat[#flat+1] = pair
        end
    end

    frame = 0
    for i,pins in ipairs(flat) do
        isSpare = false
        isStrike = false
        if pins == strike then
            isStrike = true
            pins = 10
            frame = 0
        else
            if frame > 0 then
                frame = frame + pins
                -- print('final frame',frame)
                isSpare = (frame == 10)
                frame = 0
            else
                frame = pins
            end
        end
        b = bonus[i] or 0
        --print(i,pins,b,pins*(b+1))
        score = score + (pins * (b+1))
        if isSpare or isStrike then
            bonus[i+1] = (bonus[i+1] or 0) + 1
        end
        if isStrike then
            bonus[i+2] = (bonus[i+2] or 0) + 1
        end
    end
    return score
end

function check(expected,got)
    if expected ~= got then
        print(expected,got)
        error("nope")
    else
        print(got)
    end
end

-- test data grobbed from wikipedia
check(28,calculate({strike,{3,6}}))
check(57,calculate({strike,strike,{9,0}}))
check(78,calculate({strike,strike,strike,{0,9}}))
check(46,calculate({strike,strike,{4,2}}))
check(20,calculate({{7,3},{4,2}}))

local perfect = {}
for i=1,9 do
    perfect[#perfect+1] = strike
end
perfect[10] = {10,10,10}

-- you never hit fewer than this many pins the first time
skill = 4

for i=1,5 do
    local game = table.copy(perfect)
    local derp = math.random(3,5)
    local mistook = {}
    for j=1,derp do
        n = math.random(skill,9)
        m = math.random(0,10-n)
        while true do
            mistake = math.random(1,#game)
            if mistook[mistake] == nil then 
                mistook[mistake] = true
                break
            end
        end
        if mistake == 10 and n+m == 10 then
            game[mistake] = {n,m,math.random(skill,10)}
        else
            game[mistake] = {n,m}
        end
    end
    for i,frame in ipairs(game) do
        if frame == strike then
            print(i,'strike!')
        elseif type(frame)=='table' then
            function showorderp()
                if #frame == 3 and frame[1] == 10 and frame[2] == 10 and frame[3] == 10 then
                    print(i,'strike out!')
                    return
                end
                local s = '{'
                local first = true
                for _,v in ipairs(frame) do
                    if first then
                        first = false
                    else
                        s = s .. ','
                    end
                    s = s .. v
                end
                s = s .. '}'
                if #frame == 2 and frame[1] + frame[2] == 10 then
                    s = s .. ' spare!'
                end
                print(i,s)
            end
            showorderp()
        else
            print(frame)
        end
    end
    print('mistakes',derp)
    print('score   ',calculate(game))
end
