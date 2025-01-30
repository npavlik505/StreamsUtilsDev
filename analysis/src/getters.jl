module getters
export Spans, Density,XVelocity, YVelocity, ZVelocity, Energy, spans_idx

abstract type Spans end

struct Density <: Spans end
struct XVelocity<: Spans end
struct YVelocity<: Spans end
struct ZVelocity<: Spans end
struct Energy <: Spans end

spans_idx(x::Spans) = error("unhandled type")
spans_idx(x::Density) = 1
spans_idx(x::XVelocity) = 2
spans_idx(x::YVelocity) = 3
spans_idx(x::ZVelocity) = 4
spans_idx(x::Energy) = 5

end
