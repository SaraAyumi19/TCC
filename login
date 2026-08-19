import React, {
  useState,
  useContext,
} from "react";
import {
  View,
  TextInput,
  TouchableOpacity,
  Animated,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import {
  A11yContext,
} from "./AccessibilityContext";
import styles from "./styles/styles";

export default function LoginScreen({ navigation }) {
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [erro, setErro] = useState("");

  const {
    theme,
    linkStyle,
    animFont,
    animSpace,
    fontStyle,
    titleStyle,
    buttonStyle,
    inputStyle,
    highContrast,
  } = useContext(A11yContext);

  const login = async () => {
  setErro("");

  const emailLimpo = email.trim().toLowerCase();

  if (!emailLimpo || !senha) {
    setErro("Preencha o e-mail e a senha.");
    return;
  }

  try {
    const user = await AsyncStorage.getItem(emailLimpo);

    if (!user) {
      setErro("Conta não encontrada. Registre-se primeiro.");
      return;
    }

    const dados = JSON.parse(user);

    if (dados.senha !== senha) {
      setErro("Senha incorreta. Use a mesma cadastrada.");
      return;
    }

    const isAdmin =
      dados.tipoUsuario === "admin" ||
      (
        !dados.tipoUsuario &&
        emailLimpo.includes("adm")
      );

    if (isAdmin) {
      navigation.replace("HomeAdmin", {
        userName: dados.nome,
        email: emailLimpo,
      });

      return;
    }

    if (!dados.perfilAlimentar) {
      dados.perfilAlimentar = {
        tipo: "comum",
        restricoes: [],
        outraRestricao: "",
        observacoes: "",
      };

      dados.perfilAlimentarPreenchido = false;

      await AsyncStorage.setItem(
        emailLimpo,
        JSON.stringify(dados)
      );
    }

    if (!dados.perfilAlimentarPreenchido) {
      navigation.replace("FoodPreferences", {
        email: emailLimpo,
        firstAccess: true,
      });

      return;
    }

    navigation.replace("Home", {
      userName: dados.nome,
      email: emailLimpo,
    });
  } catch (error) {
    console.log("Erro ao realizar login:", error);

    setErro(
      "Não foi possível realizar o login. Tente novamente."
    );
  }
};

  return (
    <View
      style={[
        styles.authScreen,
        {
          backgroundColor: theme.bg,
        },
      ]}
    >
      <View
        style={[
          styles.authHeader,
          {
            backgroundColor: theme.primary,
          },
        ]}
      >
        <Animated.Text
          style={[
            styles.authHello,
            titleStyle,
            {
              fontSize: Animated.multiply(animFont, 32),
              letterSpacing: animSpace,
              color: "#FFFFFF",
            },
          ]}
        >
          Olá!
        </Animated.Text>

        <Animated.Text
          style={[
            fontStyle,
            {
              marginTop: 8,
              fontSize: Animated.multiply(animFont, 14),
              letterSpacing: animSpace,
              color: "#E0F2FF",
            },
          ]}
        >
          Bem-vindo(a) ao Cardápio Digital
        </Animated.Text>
      </View>

      <View
        style={[
          styles.authCard,
          {
            backgroundColor: theme.card,
          },
        ]}
      >
        <Animated.Text
          style={[
            styles.authFormTitle,
            titleStyle,
            {
              color: theme.text,
            },
          ]}
        >
          Login
        </Animated.Text>

        {erro ? (
          <Animated.Text
            style={[
              styles.error,
              fontStyle,
              {
                color: theme.danger,
              },
            ]}
          >
            {erro}
          </Animated.Text>
        ) : null}

        <TextInput
          placeholder="Email"
          placeholderTextColor={theme.placeholder}
          selectionColor={theme.primary}
          cursorColor={theme.primary}
          autoCapitalize="none"
          keyboardType="email-address"
          value={email}
          onChangeText={setEmail}
          style={[
            styles.authInput,
            inputStyle,
            {
              backgroundColor: theme.inputBg,
              color: theme.inputText,
              borderColor: theme.border,
            },
          ]}
        />

        <TextInput
          placeholder="Senha"
          placeholderTextColor={theme.placeholder}
          selectionColor={theme.primary}
          cursorColor={theme.primary}
          secureTextEntry
          value={senha}
          onChangeText={setSenha}
          style={[
            styles.authInput,
            inputStyle,
            {
              backgroundColor: theme.inputBg,
              color: theme.inputText,
              borderColor: theme.border,
            },
          ]}
        />

        <TouchableOpacity
          style={[
            styles.authBtn,
            buttonStyle,
          ]}
          activeOpacity={0.8}
          onPress={login}
        >
          <Animated.Text
            style={[
              styles.authBtnText,
              fontStyle,
              {
                fontWeight: "bold",
                color: "#FFFFFF",
              },
            ]}
          >
            Entrar
          </Animated.Text>
        </TouchableOpacity>

        <Animated.Text
          style={[
            styles.authFooterText,
            fontStyle,
            {
              color: theme.muted,
              textAlign: "center",
            },
          ]}
        >
          Não tem conta?{" "}

          <Animated.Text
            style={[
              styles.authFooterLink,
              fontStyle,
              linkStyle,
              {
                color: theme.primary,
                fontWeight: "bold",
              },
            ]}
            onPress={() => navigation.navigate("Register")}
          >
            Cadastre-se
          </Animated.Text>
        </Animated.Text>
      </View>
    </View>
  );
}
