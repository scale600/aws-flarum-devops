import React from 'react';
import { useQuery } from '@tanstack/react-query';
import axios from 'axios';

interface Discussion {
  id: number;
  title: string;
  content: string;
  author: string;
  created_at: string;
}

const Discussions: React.FC = () => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['discussions'],
    queryFn: async () => {
      const response = await axios.get<Discussion[]>('/api/discussions');
      return response.data;
    },
  });

  if (isLoading) {
    return (
      <div className="text-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600 mx-auto"></div>
        <p className="mt-4 text-gray-600">Loading discussions...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="card bg-red-50 text-red-600">
        <h2 className="text-xl font-bold mb-2">Error Loading Discussions</h2>
        <p>Unable to fetch discussions. Please try again later.</p>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-800">Discussions</h1>
        <button className="btn-primary">New Discussion</button>
      </div>

      {data && data.length > 0 ? (
        <div className="space-y-4">
          {data.map((discussion) => (
            <div key={discussion.id} className="card hover:shadow-lg transition-shadow">
              <h3 className="text-xl font-bold mb-2">{discussion.title}</h3>
              <p className="text-gray-600 mb-4">{discussion.content}</p>
              <div className="flex justify-between items-center text-sm text-gray-500">
                <span>By {discussion.author}</span>
                <span>{new Date(discussion.created_at).toLocaleDateString()}</span>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="card text-center py-12">
          <div className="text-6xl mb-4">💬</div>
          <h2 className="text-2xl font-bold mb-2">No Discussions Yet</h2>
          <p className="text-gray-600 mb-4">
            Be the first to start a conversation!
          </p>
          <button className="btn-primary">Create First Discussion</button>
        </div>
      )}
    </div>
  );
};

export default Discussions;

