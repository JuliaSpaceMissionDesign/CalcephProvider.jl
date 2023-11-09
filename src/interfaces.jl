
"""
    CalcephProvider(file::String)
    CalcephProvider(files::Vector{String})
    
Create a `CalcephProvider` instance by loading a single or multiples ephemeris kernel 
files specified by `files`.

!!! note 
    Once the object is created kernels cannot be added nor removed from the 
    generated `CalcephProvider` instance.  

### Example 
```julia-repl
julia> eph1 = CalcephProvider("PATH_TO_KERNEL")
1-kernel CalcephProvider
 "PATH_TO_KERNEL"

julia> eph2 = CalcephProvider(["PATH_TO_KERNEL_1", "PATH_TO_KERNEL_2"])
2-kernel CalcephProvider:
 "PATH_TO_KERNEL_1"
 "PATH_TO_KERNEL_2"
```
"""
mutable struct CalcephProvider <: jEph.AbstractEphemerisProvider

    ptr::Ptr{Cvoid}
    files::Vector{String}

    function CalcephProvider(files::Vector{<:AbstractString})
        
        filepaths = unique(files)

        ptr = ccall(
            (:calceph_open_array, libcalceph), Ptr{Cvoid}, 
            (Int, Ptr{Ptr{UInt8}}), length(filepaths), filepaths
        )

        @_check_pointer ptr "Unable to open ephemeris file(s)!"
        
        # Prefetch the ephemeris data 
        stat = ccall((:calceph_prefetch, libcalceph), Int, (Ptr{Cvoid},), ptr)
        @_check_status stat "Unable to prefetch ephemeris!"

        # Create the new object and assign a destructor
        obj = new(ptr, filepaths)
        finalizer(_ephem_destructor, obj)
        return obj 

    end

end

CalcephProvider(file::AbstractString) = CalcephProvider([file])

function Base.show(io::IO, eph::CalcephProvider)
    print(io, "$(length(eph.files))-kernel CalcephProvider")
end

function Base.show(io::IO, ::MIME"text/plain", eph::CalcephProvider)
    println(io, eph, ":")
    for file in eph.files
        println(io, " $(repr(file))")
    end
end

jEph.load(::Type{CalcephProvider}, file::AbstractString) = CalcephProvider(file)

function jEph.load(::Type{CalcephProvider}, files::Vector{<:AbstractString})
    return CalcephProvider(files)
end


function jEph.ephem_position_records(eph::CalcephProvider)
    
    # Retrieve the number of available position records
    n = ccall((:calceph_getpositionrecordcount, libcalceph), Cint, (Ptr{Cvoid},), eph.ptr)

    target = Ref{Cint}(0)
    center = Ref{Cint}(0)
    t_start = Ref{Cdouble}(0.0)
    t_stop  = Ref{Cdouble}(0.0)
    axes = Ref{Cint}(0)

    recs = jEph.EphemPointRecord[]

    for j = 1:n 

        # Retrieve j-th record data 
        stat = ccall(
            (:calceph_getpositionrecordindex, libcalceph), Cint, 
            (Ptr{Cvoid}, Cint, Ref{Cint}, Ref{Cint}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cint}),
            eph.ptr, j, target, center, t_start, t_stop, axes
        )

        if stat != 0 
            push!(
                recs, 
                jEph.EphemPointRecord(target[], center[], t_start[], t_stop[], axes[])
            )
        end

    end

    return recs 

end

function jEph.ephem_orient_records(eph::CalcephProvider)

    # Retrieve the number of available position records
    n = ccall((:calceph_getorientrecordcount, libcalceph), Cint, (Ptr{Cvoid},), eph.ptr)

    target = Ref{Cint}(0)
    t_start = Ref{Cdouble}(0.0)
    t_stop  = Ref{Cdouble}(0.0)
    axes = Ref{Cint}(0)

    recs = jEph.EphemAxesRecord[]

    for j = 1:n 

        # Retrieve j-th record data 
        stat = ccall(
            (:calceph_getorientrecordindex, libcalceph), Cint, 
            (Ptr{Cvoid}, Cint, Ref{Cint}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cint}),
            eph.ptr, j, target, t_start, t_stop, axes
        )

        if stat != 0 
            push!(recs, jEph.EphemAxesRecord(target[], t_start[], t_stop[], axes[]))
        end

    end

    return recs 
end


function jEph.ephem_available_points(eph::CalcephProvider)
    rec = jEph.ephem_position_records(eph)
    tids = map(x -> x.target, rec)
    cids = map(x -> x.center, rec)

    return unique(Int64[tids..., cids...])
end

function jEph.ephem_available_axes(eph::CalcephProvider)
    rec = jEph.ephem_orient_records(eph)

    tids = map(x -> x.target, rec)
    cids = map(x -> x.axes, rec)

    return unique(Int64[tids..., cids...])
end


function jEph.ephem_timespan(eph::CalcephProvider) 
    
    first_time = Ref{Cdouble}(0)
    last_time = Ref{Cdouble}(0)
    continuous = Ref{Cint}(0)

    stat = ccall(
        (:calceph_gettimespan, libcalceph), Cint, 
        (Ptr{Cvoid}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cint}), 
        eph.ptr, first_time, last_time, continuous
    )

    @_check_status stat "unable to retrieve the ephemeris timespan."

    return first_time[], last_time[], continuous[]

end


function jEph.ephem_timescale(eph::CalcephProvider)
    return ccall((:calceph_gettimescale, libcalceph), Cint, (Ptr{Cvoid},), eph.ptr)
end


function jEph.ephem_compute!(
    res, eph::CalcephProvider, jd0::Number, time::Number,
    target::Int, center::Int, order::Int,
)

    # Set the expected units of measure
    unit = useNAIFId + unit_km + unit_sec

    stat = ccall(
        (:calceph_compute_order, libcalceph), Cint, 
        (Ptr{Cvoid}, Cdouble, Cdouble, Cint, Cint, Cint, Cint, Ref{Cdouble}),
        eph.ptr, Float64(jd0), Float64(time), target, center, unit, order, res
    )
    
    if stat == 0 
        throw(
            jEph.EphemerisError(
                "ephemeris data for point with NAIFId $target with respect to point" *
                " $center is not available at JD $(jd0+time)"
            )
        )
    end

    return nothing
end


function jEph.ephem_orient!(
    res, eph::CalcephProvider, jd0::Number, time::Number, target::Int, ::Int, order::Int
)

    # Set the expected units of measure
    unit = useNAIFId + unit_rad + unit_sec

    stat = ccall(
        (:calceph_orient_order, libcalceph), Cint, 
        (Ptr{Cvoid}, Cdouble, Cdouble, Cint, Cint, Cint, Ref{Cdouble}),
        eph.ptr, Float64(jd0), Float64(time), target, unit, order, res
    )
    
    if stat == 0 
        throw(
            jEph.EphemerisError(
                "ephemeris data for axes with NAIFId $target is not available at " * 
                "JD $(jd0+time)",
            )
        )
    end

    return nothing
end


# Low-level functions 
# ========================

function _ephem_destructor(eph::CalcephProvider)

    # This function is called by the GC when it cleans up 
    eph.ptr == C_NULL && return nothing 

    # Close the CALCEPH ephemeris handler
    ccall((:calceph_close, libcalceph), Cvoid, (Ptr{Cvoid},), eph.ptr)
    eph.ptr = C_NULL 
    return nothing

end