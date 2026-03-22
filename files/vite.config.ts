import { defineConfig, mergeConfig } from 'vite';
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default (config) => {
  return mergeConfig(config, defineConfig({
    plugins: [react(), tailwindcss()],
    server: {
      allowedHosts: true
    }
  }));
};
