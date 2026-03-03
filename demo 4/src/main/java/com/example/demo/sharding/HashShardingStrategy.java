package com.example.demo.sharding;

/**
 * Hash-based sharding strategy
 * Uses modulo operation on hash of the key to determine shard
 * Simple and commonly used for distribution
 */
public class HashShardingStrategy implements ShardingStrategy {

    @Override
    public int determineShard(Long key, int totalShards) {
        if (key == null) {
            throw new IllegalArgumentException("Sharding key cannot be null");
        }
        return Math.abs((int) (key % totalShards));
    }
}
