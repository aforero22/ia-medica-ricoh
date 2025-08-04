FROM python:3.9-slim

WORKDIR /app

# Copy the Python server and HTML files
COPY server.py .
COPY index.html .

# Install any dependencies (if needed)
RUN pip install --no-cache-dir flask

# Expose port 3000
EXPOSE 3000

# Run the server
CMD ["python", "server.py"] 