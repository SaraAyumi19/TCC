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










import {
  StyleSheet,
} from "react-native";

import {
  baseColors,
} from "../constants";

const styles = StyleSheet.create({
  splashContainer: {
    flex: 1,
    backgroundColor: baseColors.primary,
    justifyContent: "center",
    alignItems: "center",
    paddingHorizontal: 24,
  },

  splashCircle: {
    width: 180,
    height: 180,
    borderRadius: 90,
    backgroundColor: baseColors.secondary,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 32,
  },

  splashTitle: {
    color: "#fff",
    fontSize: 28,
    fontWeight: "bold",
    marginBottom: 8,
  },

  headerLogo: {
    width: 75,
    height: 75,
    resizeMode: "contain",
  },

  splashSubtitle: {
    color: "#E0F2FF",
    fontSize: 14,
    textAlign: "center",
    marginBottom: 30,
  },

  splashButton: {
    backgroundColor: "#fff",
    paddingHorizontal: 40,
    paddingVertical: 12,
    borderRadius: 30,
  },

  splashButtonText: {
    color: baseColors.primary,
    fontWeight: "bold",
    fontSize: 16,
  },

  authScreen: {
    flex:1,
    backgroundColor:baseColors.light,
    alignItems:"center"
  },

  authHeader:{
    backgroundColor:baseColors.primary,
    width:"100%",
    paddingTop:60,
    paddingBottom:40,
    paddingHorizontal:24,
    borderBottomLeftRadius:40,
    borderBottomRightRadius:40,
  },

  authHello:{
    color:"#fff",
    fontSize:32,
    fontWeight:"bold",
  },

  authSubtitle:{
    color:"#e0f2ff",
    marginTop:8,
    fontSize:14,
  },

  authCard:{
    marginTop:-30,
    backgroundColor:"#F7FAFF",
    width:"88%",
    borderRadius:30,
    paddingHorizontal:20,
    paddingVertical:24,
    elevation:4,
  },

  authFormTitle:{
    fontSize:22,
    fontWeight:"bold",
    color:baseColors.dark,
    marginBottom:16,
  },

  authInput:{
    backgroundColor:"#fff",
    borderRadius:20,
    paddingHorizontal:14,
    paddingVertical:10,
    marginTop:10,
    borderWidth:1,
    borderColor:"#dbeafe",
  },

  authBtn:{
    backgroundColor:baseColors.dark,
    paddingVertical:12,
    borderRadius:25,
    marginTop:20,
    alignItems:"center",
  },

  authBtnText:{
    color:"#fff",
    fontWeight:"bold",
    fontSize:16,
  },

  authFooterText:{
    marginTop:18,
    textAlign:"center",
    fontSize:13,
    color:"#4b5563",
  },

  authFooterLink:{
    color:baseColors.primary,
    fontWeight:"bold",
  },

  backRow:{
    flexDirection:"row",
    alignItems:"center",
    marginBottom:8,
  },

  backText:{
    marginLeft:4,
    color:baseColors.primary,
    fontSize:12,
  },

  error:{
    backgroundColor:"#ffdddd",
    padding:8,
    borderRadius:10,
    marginBottom:6,
    textAlign:"center",
    color:"red",
    fontSize:12,
  },

  success:{
    backgroundColor:"#ddffdd",
    padding:8,
    borderRadius:10,
    marginBottom:6,
    textAlign:"center",
    color:"green",
    fontSize:12,
  },

  /* HOME */
  menuContainer:{
    flex:1,
    backgroundColor:baseColors.bg,
  },

  menuHeader:{
    backgroundColor:baseColors.primary,
    paddingTop:40,
    paddingBottom:20,
    paddingHorizontal:16,
    borderBottomLeftRadius:24,
    borderBottomRightRadius:24,
  },

  menuHeaderRow:{
    flexDirection:"row",
    alignItems:"center",
    justifyContent:"space-between",
  },

  homeGreetingBlock:{
    marginTop:16,
  },

  homeGreetingSmall:{
    color:"#E0F2FF",
    fontSize:14,
  },

  homeGreetingTitle:{
    color:"#fff",
    fontSize:22,
    fontWeight:"bold",
    marginTop:2,
  },

  menuBody:{
    flex:1,
    paddingHorizontal:16,
    paddingTop:12,
    paddingBottom:72,
  },

  menuScrollContent:{
    paddingBottom:80,
  },

  searchRow:{
    flexDirection:"row",
    alignItems:"center",
    marginBottom:16,
  },

  searchBar:{
    flex:1,
    flexDirection:"row",
    alignItems:"center",
    backgroundColor:"#fff",
    borderRadius:20,
    paddingHorizontal:12,
    paddingVertical:8,
    shadowColor:"#000",
    shadowOpacity:0.05,
    shadowRadius:3,
    elevation:1,
  },

  searchInput:{
    flex:1,
    marginLeft:6,
    fontSize:14,
  },

  categoryRow:{
    flexDirection:"row",
    marginBottom:16,
    flexWrap:"wrap",
    gap:8,
  },

  categoryChip:{
    paddingHorizontal:12,
    paddingVertical:6,
    borderRadius:16,
    backgroundColor:"#fff",
    marginRight:8,
  },

  categoryChipActive:{
    backgroundColor:"#0F5CC0",
  },

  categoryChipText:{
    fontSize:13,
    color:"#6B7280",
  },

  categoryChipTextActive:{
    color:"#fff",
    fontWeight:"bold",
  },

  cardsRow:{
    flexDirection:"row",
    flexWrap:"wrap",
    justifyContent:"space-between",
  },

  card:{
    backgroundColor:"#fff",
    borderRadius:16,
    padding:12,
    width:"48%",
    marginBottom:16,
    shadowColor:"#000",
    shadowOpacity:0.08,
    shadowRadius:4,
    elevation:2,
  },

  cardImageWrapper:{
    alignItems:"center",
    marginBottom:8,
  },

  cardImage:{
    width:70,
    height:70,
    borderRadius:35,
  },

  cardHeaderRow:{
    flexDirection:"row",
    justifyContent:"space-between",
    alignItems:"center",
  },

  cardTitle:{
    fontWeight:"bold",
    fontSize:15,
    color:"#111827",
  },

  cardDescription:{
    fontSize:11,
    color:"#6B7280",
    marginVertical:4,
  },

  cardBottomRow:{
    flexDirection:"row",
    justifyContent:"space-between",
    alignItems:"center",
    marginTop:6,
  },

  cardPrice:{
    fontWeight:"bold",
    color:"#0F5CC0",
  },

  cardAddButton:{
    backgroundColor:"#0F5CC0",
    width:30,
    height:30,
    borderRadius:15,
    justifyContent:"center",
    alignItems:"center",
  },

  bottomNav:{
    position:"absolute",
    left:0,
    right:0,
    bottom:0,
    height:60,
    backgroundColor:"#fff",
    flexDirection:"row",
    justifyContent:"space-around",
    alignItems:"center",
    borderTopWidth:0.5,
    borderTopColor:"#d1d5db",
  },

  bottomNavItem:{
    alignItems:"center",
    justifyContent:"center",
  },

  bottomNavLabel:{
    fontSize:11,
    color:"#6B7280",
    marginTop:2,
  },

  bottomNavLabelActive:{
    fontSize:11,
    color:"#0F5CC0",
    marginTop:2,
    fontWeight:"bold",
  },

  avatarMiniCircle:{
    width:34,
    height:34,
    borderRadius:17,
    backgroundColor:baseColors.light,
    justifyContent:"center",
    alignItems:"center",
  },

  avatarMiniText:{
    color:baseColors.dark,
    fontWeight:"bold",
  },

  avatarMiniImage:{
    width:34,
    height:34,
    borderRadius:17,
  },


  /* SIDE MENU */

  sideMenuOverlay:{
    position:"absolute",
    top:0,
    bottom:0,
    left:0,
    right:0,
    flexDirection:"row",
  },

  sideMenuBackdrop:{
    flex:1,
    backgroundColor:"rgba(0,0,0,0.4)",
  },

  sideMenu:{
    width:"75%",
    backgroundColor:baseColors.secondary,
    paddingTop:50,
    paddingHorizontal:20,
    paddingBottom:20,
    justifyContent:"space-between",
  },

  sideMenuHeader:{
    flexDirection:"row",
    alignItems:"center",
  },

  avatarCircle:{
    width:50,
    height:50,
    borderRadius:25,
    backgroundColor:baseColors.light,
    justifyContent:"center",
    alignItems:"center",
  },

  avatarText:{
    color:baseColors.dark,
    fontWeight:"bold",
    fontSize:18,
  },

  sideUserName:{
    color:"#fff",
    fontSize:18,
    fontWeight:"bold",
  },

  sideUserEmail:{
    color:"#e0e0e0",
    fontSize:12,
  },

  sideMenuItems:{
    marginTop:30,
  },

  sideItem: {
  flexDirection: "row",
  alignItems: "center",
  paddingVertical: 14,
  paddingHorizontal: 16,
  borderRadius: 14,
  backgroundColor: "#ffffff",
  marginBottom: 10,
},

sideItemIcon: {
  width: 42,
  height: 42,
  borderRadius: 12,
  alignItems: "center",
  justifyContent: "center",
  backgroundColor: "#e9f2ff",
  marginRight: 12,
},

sideItemLabel: {
  flex: 1,
  fontSize: 16,
  fontWeight: "600",
  color: "#111827",
},

  logoutButton:{
    backgroundColor:"#fff",
    paddingVertical:10,
    borderRadius:25,
    alignItems:"center",
    flexDirection:"row",
    justifyContent:"center",
  },

  logoutText:{
    color:baseColors.secondary,
    fontWeight:"bold",
    fontSize:16,
  },

  /* DETAILS */

  detailsContainer:{
    flex:1,
    backgroundColor:baseColors.bg,
  },

  detailsHeader:{
    backgroundColor:baseColors.primary,
    paddingTop:36,
    paddingBottom:14,
    paddingHorizontal:16,
    flexDirection:"row",
    alignItems:"center",
    justifyContent:"space-between",
  },

  detailsHeaderTitle:{
    color:"#fff",
    fontSize:18,
    fontWeight:"bold",
  },

  detailsScroll:{
    paddingBottom:90,
  },

  detailsImageWrapper:{
    backgroundColor:baseColors.primary,
    alignItems:"center",
    paddingVertical:24,
  },

  detailsImage:{
    width:160,
    height:160,
    borderRadius:80,
    borderWidth:4,
    borderColor:"#fff",
  },

  detailsContent:{
    backgroundColor:"#fff",
    borderTopLeftRadius:24,
    borderTopRightRadius:24,
    marginTop:-20,
    paddingHorizontal:20,
    paddingVertical:20,
  },

  detailsTitleRow:{
    flexDirection:"row",
    justifyContent:"space-between",
    alignItems:"center",
  },

  detailsTitle:{
    fontSize:22,
    fontWeight:"bold",
    color:baseColors.text,
  },

  detailsQtyBox:{
    flexDirection:"row",
    alignItems:"center",
    borderRadius:20,
    backgroundColor:"#E5F0FF",
    paddingHorizontal:10,
    paddingVertical:4,
  },

  detailsQtyText:{
    marginHorizontal:10,
    fontWeight:"bold",
    color:"#0F5CC0",
  },

  detailsPrice:{
    fontSize:20,
    fontWeight:"bold",
    color:"#0F5CC0",
    marginTop:8,
  },

  detailsInfoRow:{
    flexDirection:"row",
    marginTop:10,
    marginBottom:16,
  },

  detailsInfoItem:{
    flexDirection:"row",
    alignItems:"center",
    marginRight:14,
  },

  detailsInfoText:{
    marginLeft:4,
    fontSize:12,
    color:"#374151",
  },

  detailsSectionTitle:{
    fontSize:16,
    fontWeight:"bold",
    color:baseColors.text,
    marginBottom:6,
  },

  detailsDescription:{
    fontSize:13,
    color:"#4B5563",
    lineHeight:18,
  },

  detailsAddButton:{
    position:"absolute",
    left:16,
    right:16,
    bottom:16,
    backgroundColor:"#0F5CC0",
    paddingVertical:14,
    borderRadius:24,
    alignItems:"center",
  },

  detailsAddButtonText:{
    color:"#fff",
    fontWeight:"bold",
    fontSize:16,
  },

  cartContent:{
    flex:1,
    padding:16,
  },

  userCartRow:{
    flexDirection:"row",
    justifyContent:"space-between",
    marginBottom:16,
  },

  cartTableHeader:{
    flexDirection:"row",
    backgroundColor:baseColors.primary,
    borderTopLeftRadius:10,
    borderTopRightRadius:10,
    paddingVertical:8,
    paddingHorizontal:4,
  },

  cartHeaderText:{
    color:"#fff",
    fontWeight:"bold",
  },

  cartRow:{
    flexDirection:"row",
    backgroundColor:"#fff",
    paddingVertical:8,
    paddingHorizontal:4,
    borderBottomWidth:1,
    borderBottomColor:"#eee",
  },

  cartCell:{
    flex:1,
    fontSize:12,
  },

  cartFooter:{
    alignItems:"flex-end",
    marginTop:10,
  },

  totalText:{
    fontSize:16,
    fontWeight:"bold",
    color:baseColors.dark,
  },

  removeButton:{
    backgroundColor:"#ff4d4d",
    paddingHorizontal:10,
    paddingVertical:4,
    borderRadius:16,
  },

  removeButtonText:{
    color:"#fff",
    fontSize:12,
    fontWeight:"bold",
  },

  backBottomButton:{
    flexDirection:"row",
    alignItems:"center",
    alignSelf:"flex-start",
    marginTop:14,
    marginBottom:6,
  },

  backBottomText:{
    color:baseColors.primary,
    fontSize:15,
    fontWeight:"bold",
  },

  finishButton:{
    backgroundColor:baseColors.secondary,
    paddingVertical:12,
    borderRadius:20,
    marginTop:8,
  },

  finishButtonText:{
    color:"#fff",
    textAlign:"center",
    fontWeight:"bold",
    fontSize:16,
  },


  profileCard:{
    backgroundColor:"#fff",
    borderRadius:16,
    padding:16,
    marginBottom:16,
    elevation:2,
  },

  profileTitle:{
    fontSize:16,
    fontWeight:"bold",
    color:baseColors.text,
    marginBottom:10,
  },

  modalBackdrop:{
    position:"absolute",
    top:0,
    left:0,
    right:0,
    bottom:0,
    backgroundColor:"rgba(0,0,0,0.35)",
  },

  settingsPopup:{
    position:"absolute",
    right:10,
    bottom:74,
    width:340,
    maxHeight:"78%",
    backgroundColor:"#111111",
    borderRadius:18,
    padding:12,
    borderWidth:1,
    borderColor:"rgba(255,255,255,0.08)",
  },

  settingsPopupHeader:{
    flexDirection:"row",
    justifyContent:"space-between",
    alignItems:"center",
    marginBottom:10,
  },

  settingsPopupTitle:{
    color:"#fff",
    fontSize:16,
    fontWeight:"bold",
  },

  previewBox:{
    backgroundColor:"#fff",
    borderRadius:14,
    padding:12,
    marginBottom:10,
  },

  previewLink:{
    marginTop:6,
  },

    chipRow: {
    flexDirection: "row",
    flexWrap: "wrap",
  },
  chip: {
    backgroundColor: "#E5E7EB",
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 12,
    marginRight: 8,
    marginBottom: 8,
  },
  chipActive: {
    backgroundColor: "#1465BB",
  },
  chipText: {
    color: "#111827",
    fontWeight: "600",
  },
  chipTextActive: {
    color: "#fff",
  },

  toggleRow: {
    backgroundColor: "#fff",
    borderRadius: 12,
    paddingVertical: 10,
    paddingHorizontal: 10,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 10,
  },

  appTitle: {
    color: "white",
    fontSize: 20,
    fontWeight: "bold",
  },
  avatarImageBig: {
    width: 50,
    height: 50,
    borderRadius: 25,
  },

  changePhotoBtn: {
    marginLeft: 12,
    marginTop: 10,
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 18,
    backgroundColor: "rgba(255,255,255,0.20)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.25)",
  },

  changePhotoBtnText: {
    color: "#fff",
    fontWeight: "bold",
    fontSize: 12,
  },

  avatarOptionsContainer: {
  flex: 1,
  width: "100%",
  justifyContent: "center",
  paddingHorizontal: 20,
  paddingBottom: 40,
},

avatarOptionButton: {
  width: "100%",
  minHeight: 72,
  borderRadius: 16,
  flexDirection: "row",
  alignItems: "center",
  paddingHorizontal: 14,
  paddingVertical: 12,
  marginBottom: 14,
},

avatarOptionIconCircle: {
  width: 46,
  height: 46,
  borderRadius: 23,
  justifyContent: "center",
  alignItems: "center",
},

avatarOptionTextArea: {
  flex: 1,
  marginHorizontal: 12,
},

avatarCancelButton: {
  alignSelf: "center",
  marginTop: 4,
  paddingHorizontal: 20,
  paddingVertical: 12,
},

avatarCharactersContent: {
  padding: 16,
  paddingBottom: 40,
},

avatarGrid: {
  width: "100%",
  flexDirection: "row",
  flexWrap: "wrap",
  justifyContent: "center",
},

avatarPickItem: {
  width: 90,
  height: 90,
  borderRadius: 45,
  justifyContent: "center",
  alignItems: "center",
  margin: 7,
  borderWidth: 1,
  overflow: "hidden",
},

avatarPickImg: {
  width: 80,
  height: 80,
  borderRadius: 40,
  resizeMode: "cover",
},

  orderCard: {
    borderRadius: 16,
    padding: 14,
    marginBottom: 12,
    elevation: 2,
    borderWidth: 1,
    borderColor: "#E5E7EB",
  },

  statusPill: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 999,
  },

  statusPending: {
    backgroundColor: "rgba(245,158,11,0.18)",
  },

  statusDelivered: {
    backgroundColor: "rgba(34,197,94,0.18)",
  },

  statusPillText: {
    fontWeight: "bold",
    color: "#111827",
    fontSize: 12,
  },

  tabChip: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 14,
    backgroundColor: "rgba(255,255,255,0.18)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.25)",
  },

  tabChipActive: {
    backgroundColor: "#ffffff",
  },

  tabChipText: {
    color: "#fff",
    fontWeight: "bold",
  },

  tabChipTextActive: {
    color: baseColors.primary,
    fontWeight: "bold",
  },

  payOption: {
    borderWidth: 2,
    borderRadius: 16,
    paddingVertical: 12,
    paddingHorizontal: 12,
    marginTop: 10,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },

  /* NOVO PERFIL */
  profileNewContainer: {
    flex: 1,
  },

  profileHero: {
    height: 260,
    justifyContent: "flex-start",
  },

  profileHeroImage: {
    resizeMode: "cover",
  },

  profileHeroOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: "rgba(0,0,0,0.35)",
  },

  profileTopBar: {
    marginTop: 38,
    paddingHorizontal: 14,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },

  profileTopBtn: {
    width: 38,
    height: 38,
    borderRadius: 19,
    backgroundColor: "rgba(255,255,255,0.18)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.22)",
    alignItems: "center",
    justifyContent: "center",
  },

  profileTopTitle: {
    color: "#fff",
    fontWeight: "800",
    fontSize: 16,
  },

  profileHeroContent: {
    paddingHorizontal: 16,
    paddingTop: 18,
    alignItems: "center",
  },

  profileAvatarWrap: {
    width: 74,
    height: 74,
    borderRadius: 37,
    backgroundColor: "rgba(255,255,255,0.22)",
    borderWidth: 2,
    borderColor: "rgba(255,255,255,0.35)",
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden",
  },

  profileAvatarImg: {
    width: 74,
    height: 74,
    borderRadius: 37,
  },

  profileAvatarTxt: {
    color: "#fff",
    fontWeight: "900",
    fontSize: 20,
  },

  profileQuote: {
    marginTop: 10,
    color: "rgba(255,255,255,0.92)",
    fontSize: 12,
    textAlign: "center",
    paddingHorizontal: 24,
  },

  profileListCard: {
    borderRadius: 18,
    padding: 14,
    borderWidth: 1,
  },

  profileSectionTitle: {
    fontWeight: "800",
    fontSize: 14,
    marginBottom: 10,
  },

  profileRow: {
    paddingVertical: 12,
    paddingHorizontal: 10,
    borderRadius: 14,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },

  profileRowIconBox: {
    width: 34,
    height: 34,
    borderRadius: 17,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#fff",
  },

  profileRowLabel: {
    fontSize: 14,
    fontWeight: "700",
  },

  profileInput: {
    borderWidth: 1,
    borderRadius: 14,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginTop: 10,
  },

  profilePrimaryBtn: {
    marginTop: 12,
    paddingVertical: 12,
    borderRadius: 16,
    alignItems: "center",
  },

  profilePrimaryBtnText: {
    color: "#fff",
    fontWeight: "900",
  },

  profileGhostBtn: {
    marginTop: 10,
    paddingVertical: 12,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
    flexDirection: "row",
    gap: 8,
    borderWidth: 1,
    backgroundColor: "#fff",
  },

  profileGhostBtnText: {
    fontWeight: "900",
  },

  foodPreferencesContent: {
  padding: 18,
  paddingBottom: 50,
},

foodIntroCard: {
  width: "100%",
  borderRadius: 16,
  borderWidth: 1,
  flexDirection: "row",
  alignItems: "center",
  padding: 14,
  marginBottom: 22,
},

foodIntroIcon: {
  width: 50,
  height: 50,
  borderRadius: 25,
  justifyContent: "center",
  alignItems: "center",
  marginRight: 12,
},

foodSectionTitle: {
  fontSize: 17,
  fontWeight: "bold",
  marginBottom: 10,
},

foodTypeCard: {
  width: "100%",
  minHeight: 74,
  borderRadius: 16,
  flexDirection: "row",
  alignItems: "center",
  paddingHorizontal: 14,
  paddingVertical: 11,
  marginBottom: 10,
},

foodTypeIcon: {
  width: 44,
  height: 44,
  borderRadius: 22,
  justifyContent: "center",
  alignItems: "center",
},

foodTypeText: {
  flex: 1,
  marginHorizontal: 11,
},

foodRestrictionGrid: {
  width: "100%",
  flexDirection: "row",
  flexWrap: "wrap",
},

foodRestrictionChip: {
  minHeight: 44,
  borderRadius: 14,
  borderWidth: 1,
  flexDirection: "row",
  alignItems: "center",
  paddingHorizontal: 11,
  paddingVertical: 8,
  marginRight: 8,
  marginBottom: 9,
},

foodInput: {
  width: "100%",
  minHeight: 50,
  borderRadius: 14,
  borderWidth: 1,
  paddingHorizontal: 13,
  paddingVertical: 10,
},

foodObservationInput: {
  width: "100%",
  minHeight: 105,
  borderRadius: 14,
  borderWidth: 1,
  paddingHorizontal: 13,
  paddingVertical: 12,
},

foodSaveButton: {
  width: "100%",
  minHeight: 54,
  borderRadius: 16,
  flexDirection: "row",
  justifyContent: "center",
  alignItems: "center",
  marginTop: 23,
},

 profileReadOnlyField: {
    width: "100%",
    minHeight: 50,
    borderRadius: 14,
    borderWidth: 1,
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 13,
    marginBottom: 12,
  },
});

export default styles;
      </View>
    </View>
  );
}
