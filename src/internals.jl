
# Constant units definitions 
const unit_km = 2
const unit_rad = 16
const unit_sec = 8
const useNAIFId = 32

# Utilities macros
macro _check_status(stat, msg)
    return quote 
        if ($(esc(stat)) == 0)
            throw(jEph.EphemerisError($(esc(msg))))
        end 
    end
end

