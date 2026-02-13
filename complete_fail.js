import http from 'k6/http';
export const options = {
  stages: [
    { duration: '30s', target: 1000 },
    { duration: '5m', target: 2000 },   // Stay at 2000 users for 5 minutes
    { duration: '30s', target: 3000 },  // Spike
    { duration: '2m', target: 3000 },   // Keep spiked
  ],
};
export default function() {
  http.get('http://todo.local/');
  http.get('http://todo.local/todos/');
  http.post('http://todo.local/login/', {username:'user_${__VU}_${__ITER}_${randomString(5)}',password:'StrongPassword123!'});
  
  // No sleep - keep hammering
}

