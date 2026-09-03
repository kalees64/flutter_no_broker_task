export const swaggerDocument = {
  openapi: '3.0.0',
  info: {
    title: 'NoBroker Enterprise Management API',
    version: '1.0.0',
    description:
      'Production-grade RESTful API for NoBroker User Management, Authentication, and Property Portal Operations.',
  },
  servers: [
    {
      url: '/api/v1',
      description: 'Default API v1 Base Path',
    },
  ],
  components: {
    securitySchemes: {
      BearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Enter your JWT access token (e.g. Bearer eyJhbG...)',
      },
    },
    schemas: {
      SuccessResponse: {
        type: 'object',
        properties: {
          success: { type: 'boolean', example: true },
          data: { type: 'object' },
        },
      },
      ErrorResponse: {
        type: 'object',
        properties: {
          success: { type: 'boolean', example: false },
          message: { type: 'string', example: 'Invalid credentials' },
          code: { type: 'string', example: 'INVALID_CREDENTIALS' },
        },
      },
      User: {
        type: 'object',
        properties: {
          id: { type: 'integer', example: 1 },
          name: { type: 'string', example: 'Rajesh Sharma' },
          email: { type: 'string', example: 'rajesh.sharma@nobroker.in' },
          phone: { type: 'string', example: '+91 9876543210' },
          role: { type: 'string', example: 'tenant', enum: ['user', 'tenant', 'owner', 'vendor', 'admin'] },
          flat_number: { type: 'string', example: 'Flat 402' },
          society_name: { type: 'string', example: 'Oakwood Residency' },
          kyc_status: { type: 'string', example: 'verified', enum: ['verified', 'pending', 'rejected'] },
          avatar_url: { type: 'string', nullable: true },
          created_at: { type: 'string', format: 'date-time' },
          updated_at: { type: 'string', format: 'date-time' },
          is_active: { type: 'boolean', example: true },
        },
      },
      PaginatedUsersResponse: {
        type: 'object',
        properties: {
          success: { type: 'boolean', example: true },
          data: {
            type: 'object',
            properties: {
              items: {
                type: 'array',
                items: { $ref: '#/components/schemas/User' },
              },
              page: { type: 'integer', example: 1 },
              totalPages: { type: 'integer', example: 5 },
              totalItems: { type: 'integer', example: 48 },
            },
          },
        },
      },
    },
  },
  paths: {
    '/auth/register': {
      post: {
        summary: 'Register a new user',
        tags: ['Auth'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['name', 'email', 'password'],
                properties: {
                  name: { type: 'string', example: 'Rajesh Sharma' },
                  email: { type: 'string', example: 'rajesh@nobroker.in' },
                  password: { type: 'string', example: 'Password123!' },
                  phone: { type: 'string', example: '+91 9876543210' },
                  role: { type: 'string', example: 'user' },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'User successfully created' },
          409: { description: 'Email or phone already registered' },
        },
      },
    },
    '/auth/login': {
      post: {
        summary: 'User Login',
        tags: ['Auth'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['identifier', 'password'],
                properties: {
                  identifier: { type: 'string', example: 'admin@nobroker.in' },
                  password: { type: 'string', example: 'AdminPass123!' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Successfully authenticated, returns access & refresh tokens' },
          401: { description: 'Invalid credentials' },
        },
      },
    },
    '/auth/refresh': {
      post: {
        summary: 'Refresh Access Token',
        tags: ['Auth'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['refreshToken'],
                properties: {
                  refreshToken: { type: 'string' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Rotated refresh token and fresh access token returned' },
          401: { description: 'Token expired or invalid' },
        },
      },
    },
    '/auth/logout': {
      post: {
        summary: 'User Logout',
        tags: ['Auth'],
        security: [{ BearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['refreshToken'],
                properties: {
                  refreshToken: { type: 'string' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Successfully revoked session' },
        },
      },
    },
    '/users': {
      get: {
        summary: 'List users with pagination, search, and filtering',
        tags: ['Users'],
        security: [{ BearerAuth: [] }],
        parameters: [
          { name: 'page', in: 'query', schema: { type: 'integer', default: 1 } },
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 10 } },
          { name: 'search', in: 'query', schema: { type: 'string' } },
          { name: 'role', in: 'query', schema: { type: 'string', enum: ['all', 'tenant', 'owner', 'vendor', 'admin', 'user'] } },
          { name: 'kycStatus', in: 'query', schema: { type: 'string', enum: ['all', 'verified', 'pending', 'rejected'] } },
          { name: 'sortBy', in: 'query', schema: { type: 'string', default: 'created_at' } },
          { name: 'sortOrder', in: 'query', schema: { type: 'string', enum: ['asc', 'desc'], default: 'desc' } },
        ],
        responses: {
          200: {
            description: 'Paginated user records',
            content: { 'application/json': { schema: { $ref: '#/components/schemas/PaginatedUsersResponse' } } },
          },
        },
      },
      post: {
        summary: 'Create a new user profile',
        tags: ['Users'],
        security: [{ BearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['name', 'email', 'password'],
                properties: {
                  name: { type: 'string', example: 'Amit Sharma' },
                  email: { type: 'string', example: 'amit.sharma@example.com' },
                  password: { type: 'string', example: 'Password123!' },
                  phone: { type: 'string', example: '+91 9123456780' },
                  role: { type: 'string', example: 'tenant' },
                  flatNumber: { type: 'string', example: 'Flat 402' },
                  societyName: { type: 'string', example: 'Oakwood Residency' },
                  kycStatus: { type: 'string', example: 'verified' },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'User created' },
          409: { description: 'Email or phone exists' },
        },
      },
    },
    '/users/{id}': {
      get: {
        summary: 'Get user details by ID',
        tags: ['Users'],
        security: [{ BearerAuth: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
        responses: {
          200: { description: 'User details found' },
          404: { description: 'User not found' },
        },
      },
      patch: {
        summary: 'Update user profile',
        tags: ['Users'],
        security: [{ BearerAuth: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  phone: { type: 'string' },
                  role: { type: 'string' },
                  flatNumber: { type: 'string' },
                  societyName: { type: 'string' },
                  kycStatus: { type: 'string' },
                  isActive: { type: 'boolean' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'User updated' },
          404: { description: 'User not found' },
        },
      },
      delete: {
        summary: 'Delete user by ID',
        tags: ['Users'],
        security: [{ BearerAuth: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
        responses: {
          200: { description: 'User deleted' },
          404: { description: 'User not found' },
        },
      },
    },
  },
};
