using Bijectors
using Random

rng = MersenneTwister(123456)

@testset "parameter wrapper" begin
    @testset "bijector" begin
        # scalar
        l = rand(rng)
        # vector
        N = 5
        v = rand(rng, N)
        # matrix
        M, M′ = 4, 7
        W = rand(rng, M, M′)

        # identity bijector
        pl = Parameter(l)
        @test l == value(pl)
        @test length(pl) == 1 == num_of_param(pl)
        @test size(pl) == ()
        pv = Parameter(v)
        @test v == value(pv)
        @test length(pv) == N == num_of_param(pv)
        @test size(pv) == (N,)
        pW = Parameter(W)
        @test W == value(pW)
        @test length(pW) == M*M′ == num_of_param(pW)
        @test size(pW) == (M, M′)

        # Exp/Log bijector
        pl_pos = Parameter(l, Val(:pos))
        @test first(pl_pos.x) == Bijectors.Log{0}()(l)
        @test value(pl_pos) == Bijectors.Exp{0}()(Bijectors.Log{0}()(l))
        pv_pos = Parameter(v, Val(:pos))
        @test pv_pos.x == Bijectors.Log{1}()(v)
        @test value(pv_pos) == Bijectors.Exp{1}()(Bijectors.Log{1}()(v))
        pW_pos = Parameter(W, Val(:pos))
        @test pW_pos.x == Bijectors.Log{2}()(W)
        @test value(pW_pos) == Bijectors.Exp{2}()(Bijectors.Log{2}()(W))
    
        # check input domain
        @test_throws DomainError Parameter(-3.0, Val(:pos))
        @test_throws DomainError Parameter(9.0, inv(Bijectors.Logit(1.3, 6.0)))
    end
end

@testset "constant" begin
    n, m = 3, 5
    V = randn(rng, n)
    M = randn(rng, n, m)
    cV = Constant(V)
    cM = Constant(M)
    @test length(cV) == n
    @test num_of_param(cV) == 0
    @test size(cV) == (n,)
    @test length(cM) == n*m
    @test num_of_param(cM) == 0
    @test size(cM) == (n, m)
    @test value(cV) == V
    @test value(cM) == M
end

@testset "multiple parameters" begin
    π_num = float(π)
    r = rand(rng)
    θ = rand(rng)*π_num
    ϕ = rand(rng)*2*π_num

    sph_coord = Parameter([r, θ, ϕ], Bijectors.Exp{0}(), 
                          inv(Bijectors.Logit(0.0, π_num)),
                          inv(Bijectors.Logit(0.0, 2*π_num)))
    @test length(sph_coord) == 3
    @test num_of_param(sph_coord) == 3
    @test size(sph_coord) == (3,)
    @test value(sph_coord) ≈ [r, θ, ϕ]
end



