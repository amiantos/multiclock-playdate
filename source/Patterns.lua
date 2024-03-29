function createRandomPattern()
	local pattern = {}
	for n=1,4,1 do
		local group = {}
		for i=1,6,1 do
			group[i] = {
				math.random(0, 359),
				math.random(0,359)
			}
		end
		pattern[n] = group
	end
	return pattern
end

numberPatterns = {
	[0] = {
		{90, 180},
		{270, 180},
		{180, 0},
		{180, 0},
		{90, 0},
		{270, 0}
	},
	[1] = {
		{225, 225},
		{180, 180},
		{225, 225},
		{180, 0},
		{225, 225},
		{0, 0}
	},
	[2] = {
		{90, 90},
		{270, 180},
		{180, 90},
		{270, 0},
		{0, 90},
		{270, 270}
	},
	[3] = {
		{90, 90},
		{270, 180},
		{90, 90},
		{0, 270},
		{90, 90},
		{270, 0}
	},
	[4] = {
		{180, 180},
		{180, 180},
		{0, 90},
		{0, 180},
		{225, 225},
		{0, 0}
	},
	[5] = {
		{180, 90},
		{270, 270},
		{0, 90},
		{270, 180},
		{90, 90},
		{270, 0}
	},
	[6] = {
		{180, 90},
		{270, 270},
		{0, 180},
		{270, 180},
		{0, 90},
		{0, 270}
	},
	[7] = {
		{90, 90},
		{270, 180},
		{225, 225},
		{180, 0},
		{225, 225},
		{0, 0}
	},
	[8] = {
		{90, 180},
		{270, 180},
		{90, 0},
		{270, 0},
		{0, 90},
		{270, 0}
	},
	[9] = {
		{90, 180},
		{270, 180},
		{90, 0},
		{0, 180},
		{90, 90},
		{270, 0}
	}

}
inwardPointPattern = {
	[1] = {
		{105, 105}, {115, 115},
		{90, 90}, {90, 90},
		{75, 75}, {65, 65},
	},
	[2] = {
		{125, 125}, {150, 150},
		{90, 90}, {90, 90},
		{55, 55}, {30, 30},
	},
	[3] = {
		{210, 210}, {235, 235},
		{270, 270}, {270, 270},
		{330, 330}, {305, 305},
	},
	[4] = {
		{245, 245}, {255, 255},
		{270, 270}, {270, 270},
		{295, 295}, {285, 285},
	},
}
halfDownHalfUp = {
	[1] = {
		{180, 180}, {180, 180},
		{180, 180}, {180, 180},
		{180, 180}, {180, 180},
	},
	[2] = {
		{180, 180}, {180, 180},
		{180, 180}, {180, 180},
		{180, 180}, {180, 180},
	},
	[3] = {
		{0, 0}, {0, 0},
		{0, 0}, {0, 0},
		{0, 0}, {0, 0},
	},
	[4] = {
		{0, 0}, {0, 0},
		{0, 0}, {0, 0},
		{0, 0}, {0, 0},
	},
}
horizontalLinesPattern = {
	[1] = {
		{90, 90}, {270, 90},
		{90, 90}, {270, 90},
		{90, 90}, {270, 90},
	},
	[2] = {
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
	},
	[3] = {
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
	},
	[4] = {
		{270, 90}, {270, 270},
		{270, 90}, {270, 270},
		{270, 90}, {270, 270},
	},
}
boxPattern = {
	[1] = {
		{90, 180}, {270, 90},
		{0, 180}, {90, 90},
		{0, 90}, {270, 90},
	},
	[2] = {
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
	},
	[3] = {
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
	},
	[4] = {
		{270, 90}, {270, 180},
		{270, 270}, {0, 180},
		{270, 90}, {0, 270},
	},
}
