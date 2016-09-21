local addonName, Driven = ...;

--Similar to UIFrameFadeIn
--Hide the frame in the end.
--Shows the frame if it's not protected - important when touching protected frames.
--It also sets the alpha to "1" after hiding.

--frame: frame to fade in/out
--duration:	time that takes the animation
--startAlpha: starting alpha
--endAlpha: ending alpha
--hideEnd: if true, hides the frame in the end.

local frameFadeManager = CreateFrame("FRAME");

local queueFrame = {};
local size = 0;

local GetTime = GetTime;


function Driven.FrameFade(frame, duration, startAlpha, endAlpha, hideEnd)

	if(size > 0) then
		if(not queueFrame[frame]) then
			size = size + 1;
		end
		queueFrame[frame] = { GetTime(), GetTime()+duration, duration, startAlpha, endAlpha, hideEnd};
		frame:SetAlpha(startAlpha);
		if(not frame:IsProtected()) then
			frame:Show();
		end
		return;
	end
	
	local currentTime, newAlpha;
	
	size = 1;
	queueFrame[frame] = { GetTime(), GetTime()+duration, duration, startAlpha, endAlpha, hideEnd};
	if(not frame:IsProtected()) then
		frame:Show();
	end
	
	frameFadeManager:SetScript("OnUpdate", function(self, elapsed)
		currentTime = GetTime();
		for frame, animationInfo in pairs(queueFrame) do
			local startTime, endTime, duration, startAlpha, endAlpha, hideEnd = unpack(animationInfo);
			
			--setting new alpha
			local timeElapsed = currentTime - startTime;
			newAlpha = endAlpha*(timeElapsed/duration) + startAlpha*((endTime - currentTime)/duration);
			
			frame:SetAlpha(newAlpha);
			
			if(currentTime > endTime) then
				frame:SetAlpha(endAlpha);
				if(hideEnd and not frame:IsProtected()) then
					frame:Hide();
					frame:SetAlpha(1);
				end
				queueFrame[frame] = nil;
				size = size - 1;
				if(size == 0) then
					self:SetScript("OnUpdate", nil);
				end
			end
		end	
	end);
	
end

-------------------------------------
--
-- Creates a Frame with a FontString inside.
-- 
-- @param #String name: frame's name
-- @param #frame parent: parent's frame
-- @param #int posX: horizontal pixels relative to parent
-- @param #int posY: vertical pixels to parent
-- @param #function onClick: function that will be executed when the frame is clicked
-- @return #frame fontFrame : frame with the fontString
--
-------------------------------------
function Driven.CreateFontFrame(name, parent, posX, posY, onClick)
	local fontFrame = CreateFrame("FRAME", "DrivenDropMenu" .. name, parent);
	fontFrame:SetSize(120,20);
	fontFrame:SetPoint("TOP", posX, posY);

	fontFrame.font = fontFrame:CreateFontString("Driven" .. name .. "Font", "OVERLAY");
	fontFrame.font:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 24, "OUTLINE");
	fontFrame.font:SetTextColor(0.5, 0.5, 0.5, 1);
	fontFrame.font:SetText(name);
	fontFrame.font:SetAllPoints();
	fontFrame.font:SetJustifyH("RIGHT");
	

	fontFrame:SetScript("OnEnter", function(self)
		self.font:SetTextColor(1, 1, 1, 1);
	end);
	fontFrame:SetScript("OnLeave", function(self)
		self.font:SetTextColor(0.5, 0.5, 0.5, 1);
	end);
	fontFrame:SetScript("OnMouseDown", onClick);

	return fontFrame;
end