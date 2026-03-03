package com.example.demo.sharding;

/**
 * Interface for sharding strategy
 * Determines which shard a record should be stored in based on a key
 */
public interface ShardingStrategy {
    /**
     * Determine the shard number for a given key
     * @param key The sharding key (e.g., student ID)
     * @param totalShards Total number of shards
     * @return Shard number (0 to totalShards-1)
     */
    int determineShard(Long key, int totalShards);
}
