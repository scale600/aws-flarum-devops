// =============================================================================
// API Service
// Centralized API communication layer
// =============================================================================

import axios, { AxiosInstance, AxiosError } from 'axios';
import type {
  Discussion,
  DiscussionCreate,
  Post,
  PostCreate,
  User,
  SystemStatus,
  ApiResponse,
  PaginatedResponse,
} from '../types';

// =============================================================================
// API Configuration
// =============================================================================

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';
const API_TIMEOUT = Number(import.meta.env.VITE_API_TIMEOUT) || 30000;

// =============================================================================
// Axios Instance Configuration
// =============================================================================

const createApiClient = (): AxiosInstance => {
  const client = axios.create({
    baseURL: API_BASE_URL,
    timeout: API_TIMEOUT,
    headers: {
      'Content-Type': 'application/json',
    },
  });

  // Request interceptor
  client.interceptors.request.use(
    (config) => {
      // Add auth token if available
      const token = localStorage.getItem('auth_token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    },
    (error) => Promise.reject(error)
  );

  // Response interceptor
  client.interceptors.response.use(
    (response) => response,
    (error: AxiosError) => {
      // Handle common errors
      if (error.response?.status === 401) {
        // Unauthorized - clear token and redirect to login
        localStorage.removeItem('auth_token');
        window.location.href = '/login';
      }
      return Promise.reject(error);
    }
  );

  return client;
};

const apiClient = createApiClient();

// =============================================================================
// API Service Functions
// =============================================================================

export const apiService = {
  // ---------------------------------------------------------------------------
  // System Endpoints
  // ---------------------------------------------------------------------------

  async getSystemStatus(): Promise<SystemStatus> {
    const response = await apiClient.get<SystemStatus>('/status');
    return response.data;
  },

  // ---------------------------------------------------------------------------
  // Discussion Endpoints
  // ---------------------------------------------------------------------------

  async getDiscussions(page = 1, perPage = 20): Promise<PaginatedResponse<Discussion>> {
    const response = await apiClient.get<PaginatedResponse<Discussion>>('/api/discussions', {
      params: { page, per_page: perPage },
    });
    return response.data;
  },

  async getDiscussion(id: number): Promise<Discussion> {
    const response = await apiClient.get<Discussion>(`/api/discussions/${id}`);
    return response.data;
  },

  async createDiscussion(data: DiscussionCreate): Promise<Discussion> {
    const response = await apiClient.post<Discussion>('/api/discussions', data);
    return response.data;
  },

  async updateDiscussion(id: number, data: Partial<DiscussionCreate>): Promise<Discussion> {
    const response = await apiClient.put<Discussion>(`/api/discussions/${id}`, data);
    return response.data;
  },

  async deleteDiscussion(id: number): Promise<void> {
    await apiClient.delete(`/api/discussions/${id}`);
  },

  // ---------------------------------------------------------------------------
  // Post Endpoints
  // ---------------------------------------------------------------------------

  async getPosts(discussionId: number, page = 1, perPage = 50): Promise<PaginatedResponse<Post>> {
    const response = await apiClient.get<PaginatedResponse<Post>>('/api/posts', {
      params: { discussion_id: discussionId, page, per_page: perPage },
    });
    return response.data;
  },

  async createPost(data: PostCreate): Promise<Post> {
    const response = await apiClient.post<Post>('/api/posts', data);
    return response.data;
  },

  async updatePost(id: number, content: string): Promise<Post> {
    const response = await apiClient.put<Post>(`/api/posts/${id}`, { content });
    return response.data;
  },

  async deletePost(id: number): Promise<void> {
    await apiClient.delete(`/api/posts/${id}`);
  },

  // ---------------------------------------------------------------------------
  // User Endpoints
  // ---------------------------------------------------------------------------

  async getUser(id: number): Promise<User> {
    const response = await apiClient.get<User>(`/api/users/${id}`);
    return response.data;
  },

  async getCurrentUser(): Promise<User> {
    const response = await apiClient.get<User>('/api/users/me');
    return response.data;
  },
};

// =============================================================================
// Error Handling Utility
// =============================================================================

export const handleApiError = (error: unknown): string => {
  if (axios.isAxiosError(error)) {
    return error.response?.data?.message || error.message || 'An error occurred';
  }
  return 'An unexpected error occurred';
};

// =============================================================================
// Export
// =============================================================================

export default apiService;

