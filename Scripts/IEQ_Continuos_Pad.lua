-- =========================================
-- IEQ CONTINUOS PAD
-- V1.0
-- =========================================

local ctx = reaper.ImGui_CreateContext('IEQ CONTINUOS PAD')

local pads = {
    "PAD_C",
    "PAD_C#",
    "PAD_D",
    "PAD_D#",
    "PAD_E",
    "PAD_F",
    "PAD_F#",
    "PAD_G",
    "PAD_G#",
    "PAD_A",
    "PAD_A#",
    "PAD_B"
}

local current_pad = nil
local master_volume = 1.0

-- =========================================
-- FIND TRACK
-- =========================================

function FindTrackByName(name)

    local track_count = reaper.CountTracks(0)

    for i = 0, track_count - 1 do

        local track = reaper.GetTrack(0, i)

        local retval, track_name = reaper.GetTrackName(track)

        if track_name == name then
            return track
        end

    end

    return nil

end

-- =========================================
-- SET TRACK VOLUME
-- =========================================

function SetTrackVolume(track, volume)

    if track then
        reaper.SetMediaTrackInfo_Value(
            track,
            "D_VOL",
            volume
        )
    end

end

-- =========================================
-- STOP ALL
-- =========================================

function StopAllPads()

    for i = 1, #pads do

        local track = FindTrackByName(pads[i])

        if track then
            SetTrackVolume(track, 0.0)
        end

    end

    current_pad = nil

end

-- =========================================
-- PLAY PAD
-- =========================================

function PlayPad(pad_name)

    for i = 1, #pads do

        local track = FindTrackByName(pads[i])

        if track then

            if pads[i] == pad_name then
                SetTrackVolume(track, master_volume)
            else
                SetTrackVolume(track, 0.0)
            end

        end

    end

    current_pad = pad_name

end

-- =========================================
-- GUI
-- =========================================

function DrawGUI()

    reaper.ImGui_SetNextWindowSize(ctx, 420, 320, reaper.ImGui_Cond_FirstUseEver())

    local visible, open = reaper.ImGui_Begin(
        ctx,
        'IEQ CONTINUOS PAD',
        true,
        reaper.ImGui_WindowFlags_NoCollapse()
    )

    if visible then

        reaper.ImGui_Text(ctx, 'CONTINUOS PAD PLAYER')
        reaper.ImGui_Separator(ctx)

        local columns = 4

        for i = 1, #pads do

            local pad_name = pads[i]

            if current_pad == pad_name then
                reaper.ImGui_PushStyleColor(
                    ctx,
                    reaper.ImGui_Col_Button(),
                    0x00AAFFFF
                )
            end

            if reaper.ImGui_Button(ctx, pad_name, 85, 40) then
                PlayPad(pad_name)
            end

            if current_pad == pad_name then
                reaper.ImGui_PopStyleColor(ctx)
            end

            if i % columns ~= 0 then
                reaper.ImGui_SameLine(ctx)
            end

        end

        reaper.ImGui_Separator(ctx)

        changed, master_volume = reaper.ImGui_SliderDouble(
            ctx,
            'Master Volume',
            master_volume,
            0.0,
            1.0
        )

        if changed and current_pad then

            local track = FindTrackByName(current_pad)

            if track then
                SetTrackVolume(track, master_volume)
            end

        end

        reaper.ImGui_Separator(ctx)

        if reaper.ImGui_Button(ctx, 'STOP', 190, 40) then
            StopAllPads()
        end

        reaper.ImGui_SameLine(ctx)

        if reaper.ImGui_Button(ctx, 'PANIC', 190, 40) then
            StopAllPads()
        end

        reaper.ImGui_Separator(ctx)

        if current_pad then
            reaper.ImGui_Text(ctx, 'ACTIVE PAD: ' .. current_pad)
        else
            reaper.ImGui_Text(ctx, 'ACTIVE PAD: NONE')
        end

        reaper.ImGui_End(ctx)

    end

    if open then
        reaper.defer(Main)
    end

end

-- =========================================
-- MAIN LOOP
-- =========================================

function Main()

    DrawGUI()

end

-- =========================================
-- START
-- =========================================

Main()
