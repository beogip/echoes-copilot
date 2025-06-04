// ECHO: diagnostic
// The user authentication is failing randomly in production
// Error: "Invalid token" but token appears valid in logs

class AuthService {
    constructor(tokenSecret, tokenExpiry = 3600) {
        this.tokenSecret = tokenSecret;
        this.tokenExpiry = tokenExpiry;
        this.cache = new Map();
    }

    async authenticateUser(token) {
        try {
            // Decode and verify JWT token
            const decoded = jwt.verify(token, this.tokenSecret);
            
            // Check if user exists and is active
            const user = await User.findById(decoded.userId);
            if (!user || !user.isActive) {
                throw new Error('User not found or inactive');
            }

            // Cache the result for 5 minutes
            this.cache.set(token, user);
            setTimeout(() => this.cache.delete(token), 300000);

            return user;
        } catch (error) {
            console.error('Authentication failed:', error.message);
            throw new Error('Invalid token');
        }
    }

    // ECHO: optimization
    // This method is called frequently and might have performance issues
    async validatePermissions(userId, resource, action) {
        // Current implementation makes multiple DB calls
        const user = await User.findById(userId);
        const permissions = await Permission.find({ userId });
        const roles = await Role.find({ userId });
        
        // Check if user has direct permission
        const hasDirectPermission = permissions.some(p => 
            p.resource === resource && p.action === action
        );
        
        // Check if user has permission through role
        const hasRolePermission = roles.some(role => 
            role.permissions.some(p => 
                p.resource === resource && p.action === action
            )
        );
        
        return hasDirectPermission || hasRolePermission;
    }
}

// ECHO: planning
// Need to implement rate limiting for API endpoints
// Requirements: 100 requests per minute per user, 1000 per minute per IP

class RateLimiter {
    constructor(redisClient) {
        this.redis = redisClient;
    }

    // Planning output will structure the implementation:
    // 1. Define rate limiting strategies (user-based, IP-based)
    // 2. Choose storage mechanism (Redis with TTL)
    // 3. Implement sliding window algorithm
    // 4. Add middleware integration
    // 5. Handle error responses and headers
    // 6. Add monitoring and alerts
}

// ECHO: evaluation
// Review this caching implementation for production readiness

class CacheManager {
    constructor() {
        this.memoryCache = new Map();
        this.redisClient = redis.createClient();
    }

    async get(key) {
        // Check memory cache first
        if (this.memoryCache.has(key)) {
            return this.memoryCache.get(key);
        }
        
        // Check Redis cache
        const value = await this.redisClient.get(key);
        if (value) {
            this.memoryCache.set(key, JSON.parse(value));
            return JSON.parse(value);
        }
        
        return null;
    }

    async set(key, value, ttl = 3600) {
        // Set in both caches
        this.memoryCache.set(key, value);
        await this.redisClient.setex(key, ttl, JSON.stringify(value));
    }
}

module.exports = { AuthService, RateLimiter, CacheManager };
