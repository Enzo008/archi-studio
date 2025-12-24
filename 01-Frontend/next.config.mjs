/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: '**.clerk.com' },
      { protocol: 'https', hostname: 'img.clerk.com' },
      { protocol: 'http', hostname: 'localhost' },
    ],
  },
}

export default nextConfig
