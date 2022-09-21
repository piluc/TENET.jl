using Test

include("../src/temporal_graph.jl")

@testset "load_temporal_graph" begin
    @testset "from sorted file" begin
        tg::temporal_graph = load_temporal_graph("graphs/test/small.txt", " ")
        @test tg.num_nodes == 5
        @test tg.temporal_edges == [(1, 2, 1), (1, 2, 2), (1, 2, 3), (1, 2, 4), (1, 2, 5), (1, 2, 6), (2, 3, 7), (2, 4, 8), (3, 4, 9), (4, 3, 10), (3, 5, 11)]
        @test tg.file_id == ["1", "2", "3", "4", "5"]
        @test tg.file_time == [1, 2, 3, 5, 6, 8, 40, 60, 100, 400, 500]
    end

    @testset "from shuffled file" begin
        tg::temporal_graph = load_temporal_graph("graphs/test/small_shuffled.txt", " ")
        @test tg.num_nodes == 5
        @test tg.temporal_edges == [(1, 2, 1), (1, 2, 2), (1, 2, 3), (1, 2, 4), (1, 2, 5), (1, 2, 6), (2, 3, 7), (2, 5, 8), (3, 5, 9), (5, 3, 10), (3, 4, 11)]
        @test tg.file_id == ["1", "2", "3", "5", "4"]
        @test tg.file_time == [1, 2, 3, 5, 6, 8, 40, 60, 100, 400, 500]
    end

    @testset "from alphabetic file" begin
        tg::temporal_graph = load_temporal_graph("graphs/test/small_alpha.txt", " ")
        @test tg.num_nodes == 5
        @test tg.temporal_edges == [(1, 2, 1), (1, 2, 2), (1, 2, 3), (1, 2, 4), (1, 2, 5), (1, 2, 6), (2, 3, 7), (2, 5, 8), (3, 5, 9), (5, 3, 10), (3, 4, 11)]
        @test tg.file_id == ["a", "b", "c", "e", "d"]
        @test tg.file_time == [1, 2, 3, 5, 6, 8, 40, 60, 100, 400, 500]
    end

    @testset "from one file" begin
        tg::temporal_graph = load_temporal_graph("graphs/test/one.txt", " ")
        @test tg.num_nodes == 1
        @test tg.temporal_edges == [(1, 1, 1)]
        @test tg.file_id == ["121"]
        @test tg.file_time == [123456789]
    end
end;

@testset "temporal_adjacency_list" begin
    @testset "from small file" begin
        tg::temporal_graph = load_temporal_graph("graphs/test/small.txt", " ")
        tal::Array{Array{Tuple{Int64,Int64}}} = temporal_adjacency_list(tg)
        @test tal[1] == [(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6)]
        @test tal[2] == [(3, 7), (4, 8)]
        @test tal[3] == [(4, 9), (5, 11)]
        @test tal[4] == [(3, 10)]
    end

    @testset "empty list" begin
        tg::temporal_graph = load_temporal_graph("graphs/test/empty.txt", " ")
        tal::Array{Array{Tuple{Int64,Int64}}} = temporal_adjacency_list(tg)
        @test tal[1] == [(2, 1)]
        @test tal[2] == []
    end

end;

@testset "temporal_neighbours" begin
    @testset "from small file" begin
        tg::temporal_graph = load_temporal_graph("graphs/test/small.txt", " ")
        tal::Array{Array{Tuple{Int64,Int64}}} = temporal_adjacency_list(tg)
        tn::Array{Tuple{Int64,Int64}} = temporal_neighbors(tal, 1, 3)
        @test tn == [(2, 4), (2, 5), (2, 6)]
        tn = temporal_neighbors(tal, 2, 3)
        @test tn == [(3, 7), (4, 8)]
        tn = temporal_neighbors(tal, 3, 12)
        @test tn == []
        tn = temporal_neighbors(tal, 4, 10)
        @test tn == []
    end

    @testset "empty list" begin
        tg::temporal_graph = load_temporal_graph("graphs/test/empty.txt", " ")
        tal::Array{Array{Tuple{Int64,Int64}}} = temporal_adjacency_list(tg)
        tn::Array{Tuple{Int64,Int64}} = temporal_neighbors(tal, 2, 1)
        @test tn == []
    end

end;
