local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local VFX_Utilities = {}

function VFX_Utilities:TweenBeams(beams: {[number]: Beam}, attachments: {[number]: Attachment}, info: TweenInfo, beamTweenData: {[number]: {any}}, attachTweenData: {[number]: {any}})
    if not info then return warn("need info for tweening beams") end
    
    if beams and beamTweenData then
        for i, beam in beams do
            TweenService:Create(beam, info, beamTweenData[i]):Play()
        end
    end
    
    if attachments and attachTweenData then
        for i, attach in attachments do
            TweenService:Create(attach, info, attachTweenData[i]):Play()
        end
    end
end

function VFX_Utilities:TweenBeamTransparency(beams: {})
    task.spawn(function()
        for i=0.5, 1, 0.05 do
            for _, beam: Beam in beams do
                beam.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, i),
                    NumberSequenceKeypoint.new(1, i)
                })
            end

            task.wait()
        end
    end)
end

function VFX_Utilities:TweenTrails()
    
end

return VFX_Utilities