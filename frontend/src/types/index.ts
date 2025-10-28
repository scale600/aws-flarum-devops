// =============================================================================
// TypeScript Type Definitions
// Central type definitions for the application
// =============================================================================

// =============================================================================
// Discussion Types
// =============================================================================

export interface Discussion {
  id: number;
  title: string;
  content: string;
  author: string;
  author_id: number;
  created_at: string;
  updated_at: string;
  view_count: number;
  reply_count: number;
  is_pinned: boolean;
  is_locked: boolean;
  tags: string[];
}

export interface DiscussionCreate {
  title: string;
  content: string;
}

export interface DiscussionUpdate {
  title?: string;
  content?: string;
}

// =============================================================================
// Post/Reply Types
// =============================================================================

export interface Post {
  id: number;
  discussion_id: number;
  content: string;
  author: string;
  author_id: number;
  created_at: string;
  updated_at: string;
  is_edited: boolean;
  likes_count: number;
}

export interface PostCreate {
  discussion_id: number;
  content: string;
}

// =============================================================================
// User Types
// =============================================================================

export interface User {
  id: number;
  username: string;
  email: string;
  avatar_url?: string;
  bio?: string;
  created_at: string;
  post_count: number;
  discussion_count: number;
  is_admin: boolean;
}

export interface UserProfile {
  id: number;
  username: string;
  avatar_url?: string;
  bio?: string;
  joined_date: string;
  post_count: number;
  discussion_count: number;
}

// =============================================================================
// API Response Types
// =============================================================================

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface ApiError {
  success: false;
  error: string;
  message: string;
  code?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    current_page: number;
    per_page: number;
    total_items: number;
    total_pages: number;
  };
}

// =============================================================================
// System Types
// =============================================================================

export interface SystemStatus {
  status: string;
  php_version: string;
  timestamp: string;
  environment: string;
}

// =============================================================================
// UI State Types
// =============================================================================

export type LoadingState = 'idle' | 'loading' | 'success' | 'error';

export interface ToastNotification {
  id: string;
  type: 'success' | 'error' | 'info' | 'warning';
  message: string;
  duration?: number;
}

