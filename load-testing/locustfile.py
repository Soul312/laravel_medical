from locust import HttpUser, task, between


class MedicalAppUser(HttpUser):
    """Simulates users browsing the Laravel Medical application."""

    wait_time = between(1, 5)
    host = "http://localhost:80"

    @task(3)
    def visit_homepage(self):
        self.client.get("/")

    @task(2)
    def visit_login_page(self):
        self.client.get("/login")

    @task(1)
    def visit_register_page(self):
        self.client.get("/register")

    @task(2)
    def health_check(self):
        self.client.get("/api/health", name="/api/health")
