import http from 'k6/http';

export default function () {
  const url = 'http://health-api.pauloponciano.digital/calculator';
  const payload = JSON.stringify({
    age: 26,
    weight: 90.0,
    height: 1.77,
    gender: 'M',
    activity_intensity: 'very_active',
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const response = http.post(url, payload, params);
  console.log(response.body);
}
