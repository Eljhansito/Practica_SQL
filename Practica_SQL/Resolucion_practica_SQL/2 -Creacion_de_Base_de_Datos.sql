-- Program (Bootcamp)

CREATE TABLE program (
  program_id     SERIAL PRIMARY KEY,
  name           VARCHAR(255),
  modality       VARCHAR(50),     -- online / hybrid / in_person
  duration_hours INT
);

-- Instructor (Profesor)

CREATE TABLE instructor (
  instructor_id SERIAL PRIMARY KEY,
  name          VARCHAR(255),
  surname       VARCHAR(255),
  email         VARCHAR(255)
);

ALTER TABLE instructor
  ADD CONSTRAINT uk_instructor_email UNIQUE (email);

-- Edition (Edición)

CREATE TABLE edition (
  edition_id SERIAL PRIMARY KEY,
  program_id INT,                 -- FK → program
  code       VARCHAR(50),
  start_date DATE,
  end_date   DATE,
  status     VARCHAR(50),
  CONSTRAINT fk_edition_program
    FOREIGN KEY (program_id) REFERENCES program(program_id)
);

ALTER TABLE edition
  ADD CONSTRAINT uk_edition_program_code UNIQUE (program_id, code);


-- Module (Módulo)

CREATE TABLE module (
  module_id  SERIAL PRIMARY KEY,
  edition_id INT,                 -- FK → edition
  title      VARCHAR(255),
  order_no   INT,
  hours      INT,
  CONSTRAINT fk_module_edition
    FOREIGN KEY (edition_id) REFERENCES edition(edition_id)
);

ALTER TABLE module
  ADD CONSTRAINT uk_module_title  UNIQUE (edition_id, title);
ALTER TABLE module
  ADD CONSTRAINT uk_module_order  UNIQUE (edition_id, order_no);


-- Session (Clase)

CREATE TABLE session (
  session_id    SERIAL PRIMARY KEY,
  module_id     INT,              -- FK → module
  instructor_id INT,              -- FK → instructor
  start_at      TIMESTAMP,
  end_at        TIMESTAMP,
  delivery_mode VARCHAR(50),      -- online / in_person / hybrid
  CONSTRAINT fk_session_module
    FOREIGN KEY (module_id) REFERENCES module(module_id),
  CONSTRAINT fk_session_instructor
    FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id)
);
CREATE INDEX idx_session_start_at ON session(start_at);


-- Student (Alumno)

CREATE TABLE student (
  student_id SERIAL PRIMARY KEY,
  name       VARCHAR(255),
  surname    VARCHAR(255),
  email      VARCHAR(255)
);
ALTER TABLE student
  ADD CONSTRAINT uk_student_email UNIQUE (email);


-- Enrollment (Matrícula)

CREATE TABLE enrollment (
  enrollment_id SERIAL PRIMARY KEY,
  student_id    INT,              -- FK → student
  edition_id    INT,              -- FK → edition
  status        VARCHAR(50),      -- applied / enrolled / dropped / completed
  enrolled_on   DATE,
  price         DECIMAL(10,2),
  CONSTRAINT fk_enrollment_student
    FOREIGN KEY (student_id) REFERENCES student(student_id),
  CONSTRAINT fk_enrollment_edition
    FOREIGN KEY (edition_id) REFERENCES edition(edition_id)
);

-- Un alumno no puede matricularse dos veces en la misma edición

ALTER TABLE enrollment
  ADD CONSTRAINT uk_enrollment_student_edition UNIQUE (student_id, edition_id);

CREATE INDEX idx_enrollment_student ON enrollment(student_id);
CREATE INDEX idx_enrollment_edition ON enrollment(edition_id);


-- Payment (Pago)

CREATE TABLE payment (
  payment_id    SERIAL PRIMARY KEY,
  enrollment_id INT,              -- FK → enrollment
  amount        DECIMAL(10,2),
  paid_at       TIMESTAMP,
  method        VARCHAR(50),      -- card / transfer / cash / other
  status        VARCHAR(50),      -- pending / paid / failed / refunded
  CONSTRAINT fk_payment_enrollment
    FOREIGN KEY (enrollment_id) REFERENCES enrollment(enrollment_id)
);
CREATE INDEX idx_payment_enrollment ON payment(enrollment_id);
CREATE INDEX idx_payment_paid_at    ON payment(paid_at);


-- Assignment (Tarea)

CREATE TABLE assignment (
  assignment_id SERIAL PRIMARY KEY,
  module_id     INT,              -- FK → module
  title         VARCHAR(255),
  due_at        TIMESTAMP,
  max_points    INT,
  CONSTRAINT fk_assignment_module
    FOREIGN KEY (module_id) REFERENCES module(module_id)
);
ALTER TABLE assignment
  ADD CONSTRAINT uk_assignment_module_title UNIQUE (module_id, title);
CREATE INDEX idx_assignment_module ON assignment(module_id);


-- Submission (Entrega)

CREATE TABLE submission (
  submission_id SERIAL PRIMARY KEY,
  assignment_id INT,              -- FK → assignment
  student_id    INT,              -- FK → student
  submitted_at  TIMESTAMP,
  grade         DECIMAL(5,2),
  feedback      TEXT,
  CONSTRAINT fk_submission_assignment
    FOREIGN KEY (assignment_id) REFERENCES assignment(assignment_id),
  CONSTRAINT fk_submission_student
    FOREIGN KEY (student_id) REFERENCES student(student_id)
);

-- Una entrega por alumno y tarea

ALTER TABLE submission
  ADD CONSTRAINT uk_submission_assignment_student UNIQUE (assignment_id, student_id);
CREATE INDEX idx_submission_assignment ON submission(assignment_id);
CREATE INDEX idx_submission_student    ON submission(student_id);


-- Material (Recurso)

CREATE TABLE material (
  material_id SERIAL PRIMARY KEY,
  module_id   INT,                -- FK → module
  title       VARCHAR(255),
  url         TEXT,
  type        VARCHAR(50),
  CONSTRAINT fk_material_module
    FOREIGN KEY (module_id) REFERENCES module(module_id)
);
ALTER TABLE material
  ADD CONSTRAINT uk_material_module_title UNIQUE (module_id, title);
CREATE INDEX idx_material_module ON material(module_id);
