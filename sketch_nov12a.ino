
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// =============================================
// 1. WIFI
// =============================================

const char* WIFI_SSID = "Banho de caneca";
const char* WIFI_PASSWORD = "kakaka123";

// =============================================
// 2. SUPABASE
// =============================================

const char* SUPABASE_URL =
  "https://akkaoetdwemfdgbrpgvp.supabase.co";

const char* SUPABASE_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFra2FvZXRkd2VtZmRnYnJwZ3ZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQxMzYzNjMsImV4cCI6MjA5OTcxMjM2M30.ge-PBsxSpYLM6jk6MTtf5jr-yCsQ1r9zjChyAZxIWI8";

// Identificacao do dispositivo
const char* DEVICE_ID = "ESP32_001";

// =============================================
// 3. PINOS
// =============================================

const int SENSOR_PIN = 34;
const int BOMBA_PIN = 26;

// =============================================
// 4. CALIBRACAO DO SENSOR
// =============================================

// Valores iniciais provisórios.
// Calibrar com o sensor seco e em solo úmido.

int VALOR_SECO = 3900;
int VALOR_MOLHADO = 1600;

// =============================================
// 5. CONTROLE DA BOMBA
// =============================================

const float LIMITE_LIGAR = 50.0;
const float LIMITE_DESLIGAR = 70.0;

const int RELE_LIGADO = HIGH;
const int RELE_DESLIGADO = LOW;

bool bombaLigada = false;

// =============================================
// 6. INTERVALO DE LEITURA
// =============================================

unsigned long ultimaLeitura = 0;

const unsigned long INTERVALO_LEITURA = 30000;

// =============================================
// 7. CONEXAO WIFI
// =============================================

bool conectarInternet() {

  if (WiFi.status() == WL_CONNECTED) {
    return true;
  }

  Serial.println("Conectando ao Wi-Fi...");

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  unsigned long inicio = millis();

  while (
    WiFi.status() != WL_CONNECTED &&
    millis() - inicio < 15000
  ) {
    delay(500);
    Serial.print(".");
  }

  if (WiFi.status() == WL_CONNECTED) {

    Serial.println("\nWi-Fi conectado!");

    Serial.print("IP: ");
    Serial.println(WiFi.localIP());

    return true;
  }

  Serial.println("\nFalha na conexao Wi-Fi!");

  return false;
}

// =============================================
// 8. LEITURA MEDIA DO SENSOR
// =============================================

int lerSensor() {

  long soma = 0;

  for (int i = 0; i < 20; i++) {

    soma += analogRead(SENSOR_PIN);

    delay(20);
  }

  return soma / 20;
}

// =============================================
// 9. CALCULAR UMIDADE
// =============================================


float calcularUmidade(int leitura) {

  // VALORES PROVISORIOS.
  // Precisam ser calibrados com seu sensor.

  const int VALOR_SECO = 4095;
  const int VALOR_MOLHADO = 1500;

  float porcentagem =
    ((float)(VALOR_SECO - leitura) /
    (VALOR_SECO - VALOR_MOLHADO)) * 100.0;

  porcentagem = constrain(
    porcentagem,
    0.0,
    100.0
  );

  return porcentagem;
}


// =============================================
// 10. ENVIAR DADOS AO SUPABASE
// =============================================

bool enviarSupabase(
  const char* tabela,
  JsonDocument& dados
) {

  if (!conectarInternet()) {

    Serial.println("Sem internet.");

    return false;
  }

  String url =
    String(SUPABASE_URL) +
    "/rest/v1/" +
    tabela;

  String json;

  serializeJson(dados, json);

  WiFiClientSecure cliente;

  // Apenas para testes.
  // Em producao, configure o certificado CA.

  cliente.setInsecure();

  HTTPClient http;

  if (!http.begin(cliente, url)) {

    Serial.println("Erro ao iniciar HTTPS.");

    return false;
  }

  http.addHeader(
    "Content-Type",
    "application/json"
  );

  http.addHeader(
    "apikey",
    SUPABASE_KEY
  );

  http.addHeader(
    "Authorization",
    String("Bearer ") + SUPABASE_KEY
  );

  http.addHeader(
    "Prefer",
    "return=minimal"
  );

  int resposta = http.POST(json);

  Serial.print("Tabela: ");
  Serial.println(tabela);

  Serial.print("Resposta Supabase: ");
  Serial.println(resposta);

  if (resposta < 200 || resposta >= 300) {

    Serial.println(http.getString());

  }

  http.end();

  return resposta >= 200 && resposta < 300;
}

// =============================================
// 11. SALVAR LEITURA E HISTORICO
// =============================================

void salvarLeitura(
  int valorSensor,
  float umidade
) {

  JsonDocument dados;

  dados["sensor_id"] = DEVICE_ID;
  dados["valor_sensor"] = valorSensor;
  dados["umidade"] = umidade;
  dados["umidade_percentual"] = umidade;

  Serial.println("Enviando leitura para o Supabase...");

  bool leituraSalva = enviarSupabase(
    "leituras_umidade",
    dados
  );

  if (leituraSalva) {
    Serial.println("Leitura salva com sucesso!");
  } else {
    Serial.println("Erro ao salvar leitura!");
  }
}

// =============================================
// 12. REGISTRAR EVENTOS DA BOMBA
// =============================================

void salvarEvento(
  const char* evento,
  float umidade
) {

  JsonDocument dados;

  dados["sensor_id"] = DEVICE_ID;
  dados["evento"] = evento;
  dados["umidade"] = umidade;

  enviarSupabase(
    "eventos_bomba",
    dados
  );
}

// =============================================
// 13. CONTROLE AUTOMATICO DA BOMBA
// =============================================

void controlarBomba(float umidade) {

  // LIGAR ABAIXO DE 50%

  if (
    umidade < LIMITE_LIGAR &&
    !bombaLigada
  ) {

    digitalWrite(
      BOMBA_PIN,
      RELE_LIGADO
    );

    bombaLigada = true;

    Serial.println("MINIBOMBA LIGADA!");

    salvarEvento(
      "ligada",
      umidade
    );
  }

  // DESLIGAR ACIMA DE 70%

  else if (
    umidade > LIMITE_DESLIGAR &&
    bombaLigada
  ) {

    digitalWrite(
      BOMBA_PIN,
      RELE_DESLIGADO
    );

    bombaLigada = false;

    Serial.println("MINIBOMBA DESLIGADA!");

    salvarEvento(
      "desligada",
      umidade
    );
  }
}

// =============================================
// 14. SETUP
// =============================================

void setup() {

  Serial.begin(115200);

  analogReadResolution(12);

  pinMode(
    SENSOR_PIN,
    INPUT
  );

  pinMode(
    BOMBA_PIN,
    OUTPUT
  );

  digitalWrite(
    BOMBA_PIN,
    RELE_DESLIGADO
  );

  bombaLigada = false;

  Serial.println();
  Serial.println("==============================");
  Serial.println(" SISTEMA DE IRRIGACAO ESP32");
  Serial.println("==============================");

  conectarInternet();

  // Primeira leitura sera feita imediatamente.
  ultimaLeitura = millis() - INTERVALO_LEITURA;
}

// =============================================
// 15. LOOP PRINCIPAL
// =============================================

void loop() {

  unsigned long agora = millis();

  if (
    agora - ultimaLeitura >=
    INTERVALO_LEITURA
  ) {

    ultimaLeitura = agora;

    // Ler sensor com media de 20 amostras
    int valorSensor = lerSensor();

    // Calcular porcentagem
    float umidade = calcularUmidade(
      valorSensor
    );

    Serial.println();
    Serial.println("==============================");

    Serial.print("Leitura do sensor: ");
    Serial.println(valorSensor);

    Serial.print("Umidade do solo: ");
    Serial.print(umidade, 1);
    Serial.println("%");

    // Controlar bomba
    controlarBomba(umidade);

    // Enviar ao Supabase
    salvarLeitura(
      valorSensor,
      umidade
    );

    Serial.print("Estado da bomba: ");

    Serial.println(
      bombaLigada ? "LIGADA" : "DESLIGADA"
    );

    Serial.println("==============================");
  }

  delay(10);
}
