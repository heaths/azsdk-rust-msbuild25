document.addEventListener('DOMContentLoaded', function () {
  const uploadArea = document.getElementById('uploadArea');
  const fileInput = document.getElementById('fileInput');
  const fileSelectBtn = document.getElementById('fileSelectBtn');
  const uploadStatus = document.getElementById('uploadStatus');
  const progressBar = document.getElementById('progressBar');
  const progress = document.getElementById('progress');

  // Handle file select button click
  fileSelectBtn.addEventListener('click', function () {
    fileInput.click();
  });

  // Handle file selection via input
  fileInput.addEventListener('change', function () {
    if (fileInput.files.length > 0) {
      uploadFile(fileInput.files[0]);
    }
  });

  // Handle drag and drop events
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    uploadArea.addEventListener(eventName, preventDefaults, false);
  });

  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  ['dragenter', 'dragover'].forEach(eventName => {
    uploadArea.addEventListener(eventName, highlight, false);
  });

  ['dragleave', 'drop'].forEach(eventName => {
    uploadArea.addEventListener(eventName, unhighlight, false);
  });

  function highlight() {
    uploadArea.classList.add('dragover');
  }

  function unhighlight() {
    uploadArea.classList.remove('dragover');
  }

  uploadArea.addEventListener('drop', handleDrop, false);

  function handleDrop(e) {
    const dt = e.dataTransfer;
    const files = dt.files;

    if (files.length > 0) {
      uploadFile(files[0]);
    }
  }

  function uploadFile(file) {
    const formData = new FormData();
    formData.append('file', file);

    uploadStatus.textContent = `Uploading: ${file.name}`;
    progressBar.style.display = 'block';
    progress.style.width = '0%';

    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/api/upload', true);

    xhr.upload.addEventListener('progress', function (e) {
      if (e.lengthComputable) {
        const percentComplete = (e.loaded / e.total) * 100;
        progress.style.width = percentComplete + '%';
      }
    });

    xhr.onload = function () {
      if (xhr.status === 200) {
        uploadStatus.textContent = 'Upload successful!';
      } else {
        const response = xhr.responseText;
        if (response) {
          uploadStatus.textContent = 'Upload failed: ' + response;
        } else {
          uploadStatus.textContent = 'Upload failed. Please try again.';
        }
      }
    };

    xhr.onerror = function () {
      uploadStatus.textContent = 'Upload failed. Please try again.';
    };

    xhr.send(formData);
  }
});
