-- ppl.lua
-- pezak 2024
-- v 0.23

function main()
    print("ppl.lua")
    print("")
    print("small macro that uses a set of spells currently memmed to buff and heal.")
    print("")
    print("target the character that is to be healed and it will immediately begin.")
    print("if you add targets to XTarget window it will try to heal those instead.")
    print("remember if you change anything in XTarget the macro has to be restarted.")
    print("will heal over time at < 85% hp and use the other heal at < 45% hp.")
    print("(default values, feel free to change them. gem1pct and gem2pct variables).")
    print("")
    print("spell slots to use:")
    print("")
    print("gem1: quick/normal heal spell. at lower levels i use lower level heals.")
    print("gem2: duration heal spell that will take hold on lowlvl char.")
    print("gem3: higher lvl heal that will be used on healer if below 50% hps.")
    print("gem4: buff1")
    print("gem5: buff2")
    print("gem6: buff3")
    print("gem7: debuff 1 (ie root)")
    print("gem8: debuff 2 (ie mark of sandral)")
    print("")
    print("if you for some reason want to disable i.e the heals, remove any spells memmed in gem1, gem2 and gem3.")
    print("same with the buff and debuff gems.")
    print("")
    print("if your lowlvl char is killed remember to restart if it fails to find new id for target.")
    print("")
    print("this uses nav to follow the player if the switch follow is added when starting:")
    print("ppl.lua follow")
end

-- Declare variables
local Victim = mq.TLO.Target.ID()
local Victimname = mq.TLO.Target.CleanName()
local verbose = print
local i = 0
local selfhealpct = 50 -- start pct for self heal
local gem1pct = 45 -- start pct for quick/big heal
local gem2pct = 85 -- start pct for heal over time spell
local followdistance = 70 -- distance while following
local mount = "auto" -- mount item name (will try to pick one automatically if set to "auto")
local usemount = true -- use mount, set to false to not use it
local xtheal = false -- xtarget heal turns on if one or more xtarget set
local xtworstid = 0
local xtworsthp = 100
local xtloop = 0
local startzone = mq.TLO.Zone.ID()

-- Check if a target is selected
if not Victim then
    print("\arYou failed to target someone. Victimname is not valid. Please restart the macro with someone targeted.")
    return
else
    print("\agTrying to help " .. Victimname .. "!")
end
-- Function to cast a spell from a gem
local function castGem(gem)
    mq.cmdf('/cast %d', gem)
    mq.delay(5000, function() return not mq.TLO.Me.Casting() end)
end

-- Function to check and cast buffs
local function checkBuffs()
    for i = 4, 6 do
        if mq.TLO.Me.Gem(i).ID() == 0 then
            print(string.format("\ayNo Spell in Gem %d", i))
        elseif not mq.TLO.Me.SpellReady(mq.TLO.Me.Gem(i)()) then
            print(string.format("\aySpell \ap%s \axisn't ready.", mq.TLO.Me.Gem(i)()))
        elseif mq.TLO.Me.CurrentMana() < mq.TLO.Me.Spell(mq.TLO.Me.Gem(i)()).Mana() then
            print(string.format("\ayI don't have enough mana for \ap%s", mq.TLO.Me.Gem(i)()))
        elseif mq.TLO.Target.Distance() > mq.TLO.Me.Gem(i).Range() then
            print(string.format("\ap%s\ay is out of range of \ap%s", mq.TLO.Target.CleanName(), mq.TLO.Me.Gem(i)()))
        elseif mq.TLO.Me.Gem(i).Trigger(1)() and mq.TLO.Target.BuffDuration(mq.TLO.Me.Gem(i).Trigger(1)()) >= 1 then
            print(string.format("\ayAlready has the buff \ap%s", mq.TLO.Me.Gem(i)()))
        elseif not mq.TLO.Me.Gem(i).Trigger(1)() and mq.TLO.Target.BuffDuration(mq.TLO.Me.Gem(i)()) >= 1 then
            print(string.format("\ayAlready has the buff \ap%s", mq.TLO.Me.Gem(i)()))
        else
            print(string.format("buffing %s on %s", mq.TLO.Me.Gem(i)(), mq.TLO.Target.CleanName()))
            castGem(i)
            break
        end
    end
end

-- Main function
local function main()
    if mq.TLO.Me.Gem(3).ID() ~= 0 and mq.TLO.Me.PctHPs() < selfhealpct then
        mq.cmdf('/target id %d', mq.TLO.Me.ID())
        print(string.format("casting %s on myself", mq.TLO.Me.Gem(3)()))
        castGem(3)
    end

    if param0 == "follow" then
        follow()
    end

    if usemount then
        checkMount(mount)
    end

    if Victim and mq.TLO.Spawn(Victim).Distance() <= followdistance + 2 then
        mq.cmdf('/target id %d', Victim)
        healTarget()

        if xtheal then
            xtworsthp = 100
            xtworstid = 0
            for xtloop = 1, mq.TLO.Me.XTarget() do
                if mq.TLO.Me.XTarget(xtloop).TargetType():find("Specific") then
                    if mq.TLO.Me.XTarget(xtloop).PctHPs() >= xtworsthp then
                        goto continue
                    end
                    if mq.TLO.Me.XTarget(xtloop).Hovering() or mq.TLO.Me.XTarget(xtloop).Dead() then
                        goto continue
                    end
                    xtworstid = mq.TLO.Me.XTarget(xtloop).ID()
                    xtworsthp = mq.TLO.Me.XTarget(xtloop).PctHPs()
                end
                ::continue::
            end

            if xtworstid and xtworsthp < gem2pct then
                mq.cmdf('/target id %d', xtworstid)
                healTarget()
            end
        end

        mq.cmdf('/target id %d', Victim)
        checkBuffs()

        for i = 7, 8 do
            if mq.TLO.Me.Gem(i).ID() ~= 0 and mq.TLO.Me.TargetOfTarget().ID() ~= 0 then
                debuff(mq.TLO.Me.TargetOfTarget().ID(),
    -- Function to heal the target
local function healTarget()
    print(string.format("\ayTrying to heal \ap%s", mq.TLO.Target.CleanName()))

    if mq.TLO.Me.Gem(1).ID() ~= 0 then
        if mq.TLO.Target.Distance() < mq.TLO.Me.Gem(1).Range() and mq.TLO.Me.SpellReady(mq.TLO.Me.Gem(1)()) and mq.TLO.Target.PctHPs() < gem1pct and mq.TLO.Me.CurrentMana() > mq.TLO.Me.Spell(mq.TLO.Me.Gem(1)()).Mana() then
            print(string.format("casting %s on %s", mq.TLO.Me.Gem(1)(), mq.TLO.Target.CleanName()))
            castGem(1)
        end
    else
        print("\arNo spell in gem 1. Skipping.")
    end

    if mq.TLO.Me.Gem(2).ID() ~= 0 then
        if mq.TLO.Target.Distance() < mq.TLO.Me.Gem(2).Range() and mq.TLO.Me.SpellReady(mq.TLO.Me.Gem(2)()) and mq.TLO.Target.PctHPs() < gem2pct and mq.TLO.Target.BuffDuration(mq.TLO.Me.Gem(2)()) < 1 and mq.TLO.Me.CurrentMana() > mq.TLO.Me.Spell(mq.TLO.Me.Gem(2)()).Mana() then
            print(string.format("casting %s on %s", mq.TLO.Me.Gem(2)(), mq.TLO.Target.CleanName()))
            castGem(2)
        end
    else
        print("\arNo spell in gem 2. Skipping.")
    end
end

-- Function to debuff a target
local function debuff(s, k)
    if mq.TLO.Spawn(s).Type() == "npc" and mq.TLO.Spawn(s).BuffDuration(mq.TLO.Me.Gem(k)()) < 1 and mq.TLO.Spawn(s).Distance() < mq.TLO.Me.Gem(k).Range() and mq.TLO.Spawn(s).PctHPs() < 100 and mq.TLO.Spawn(s).LineOfSight() then
        print(string.format("\ayTrying to debuff \ap%s", mq.TLO.Spawn(s).CleanName()))
        mq.cmdf('/target id %d', s)
        mq.delay(3000, function() return mq.TLO.Target.BuffsPopulated() end)
        if mq.TLO.Target.BuffDuration(mq.TLO.Me.Gem(k)()) < 1 and mq.TLO.Me.CurrentMana() > mq.TLO.Me.Spell(mq.TLO.Me.Gem(k)()).Mana() then
            print(string.format("trying to debuff %s with %s", mq.TLO.Target.CleanName(), mq.TLO.Me.Gem(k)()))
            castGem(k)
        end
        mq.cmdf('/target id %d', Victim)
    end
end

-- Function to follow the target
local function follow()
    while mq.TLO.Spawn(Victim).Distance() > followdistance do
        if not mq.TLO.Navigation.Active() then
            mq.cmdf('/nav id %d distance=%d', Victim, math.floor(followdistance * 0.7))
        end
        while mq.TLO.Navigation.Active() do
            mq.delay(5000)
        end
        mq.delay(5000, function() return not mq.TLO.Navigation.Active() or mq.TLO.Spawn(Victim).Distance3D() <= followdistance end)
    end
end

-- Function to check and use mount
local function checkMount(mount)
    if not mq.TLO.Me.BodyWet() and mq.TLO.Zone.Outdoor() and mq.TLO.FindItemCount(mount) > 0 then
        if mq.TLO.Me.Mount.ID() == 0 then
            print("using mount")
            mq.cmdf('/useitem %s', mount)
            mq.delay(5000, function() return not mq.TLO.Me.Casting() end)
        end
    end
end

-- Function to rez the victim
local function rezVictim(playerToRez)
    print(string.format("\ay%s", mq.TLO.Spawn(Victimname).State()))
    if mq.TLO.Spawn(Victimname).State() == "STUN" or mq.TLO.Spawn(Victimname).State() == "DEAD" then
        print(string.format("\agAttempting to rez \ap%s", playerToRez))
        print("\aySeems the player I was meant to help has perished. Man I suck at my job. Guess I better rez them.")
        mq.cmdf('/target %s', Victimname)
        while true do
            mq.delay(5000)
            if not mq.TLO.Me.Casting.ID() and not mq.TLO.Me.Hovering() then
                break
            end
        end
        if mq.TLO.Me.AltAbility("Blessing of Resurrection").ID() and mq.TLO.Spawn(Victimname).Distance3D() < mq.TLO.Spell(mq.TLO.Me.AltAbility("Blessing of Resurrection").ID()).Range() then
            print("\ayCasting Blessing of Resurrection")
            mq.cmdf('/alt act %d', mq.TLO.Me.AltAbility("Blessing of Resurrection").ID())
        else
            print("\arThere was an issue trying to use Blessing of Resurrection.")
            print(string.format("\ay%s distance: \ap%d", Victimname, mq.TLO.Spawn(Victimname).Distance3D()))
            print(string.format("\ayBlessing of Resurrection range \ap%d", mq.TLO.Spell(mq.TLO.Me.AltAbility("Blessing of Resurrection").ID()).Range()))
        end
        mq.delay(2000, function() return mq.TLO.Me.Casting.ID() end)
        mq.delay(5000, function() return not mq.TLO.Me.Casting.ID() end)
        mq.delay(2000, function() return mq.TLO.Spawn(Victim).CleanName() == Victimname end)
    end
end

-- Function to target by name
local function targetByName(targetName)
    if mq.TLO.Target.ID() ~= mq.TLO.Spawn(targetName).ID() then
        print(string.format("\ayAttempting to target \ap%s!", targetName))
        while true do
            mq.cmdf('/target id %d', mq.TLO.Spawn(targetName).ID())
            mq.delay(5000, function() return mq.TLO.Target.ID() == mq.TLO.Spawn(targetName).ID() end)
            if mq.TLO.Target.ID() == mq.TLO.Spawn(targetName).ID() then
                break
            end
        end
    else
        print(string.format("\ap%s\ay is already my target.", targetName))
    end
end

-- Function to target by ID
local function targetByID(targetID)
    if mq.TLO.Target.ID() ~= targetID then
        print(string.format("\ayAttempting to target \ap%s!", mq.TLO.Spawn(targetID).CleanName()))
        while true do
            mq.cmdf('/target id %d', targetID)
            mq.delay(5000, function() return mq.TLO.Target.ID() == targetID end)
            if mq.TLO.Target.ID() == targetID then
                break
            end
        end
    else
        print(string.format("\ap%s\ay is already my target.", mq.TLO.Spawn(targetID).CleanName()))
    end
end

-- Function to wait for casting to complete
local function waitForCast()
    mq.delay(2000, function() return mq.TLO.Me.Casting.ID() end)
    mq.delay(10000, function() return not mq.TLO.Me.Casting.ID() end)
end

-- Function to cast a spell from a gem
local function castGem(gem)
    print(string.format("\a-tCasting \ag%s", mq.TLO.Me.Gem(gem).Name()))
    mq.cmdf('/cast %d', gem)
end

main()
