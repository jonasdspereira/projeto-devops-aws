# Projeto DevOps AWS - Infraestrutura como Código

## 👥 Equipe

### Squad5 - Bootcamp DevOps

| Nome                           | LinkedIn                                                  |
| ------------------------------ | --------------------------------------------------------- |
| Ereikson Mendes dos Santos     | [LinkedIn](https://www.linkedin.com/in/ereikson/)         |
| Jonas de Souza Pereira         | [LinkedIn](https://www.linkedin.com/in/jnsprr/)           |
| Karina Freitas Faqueti Sampaio | [LinkedIn](https://www.linkedin.com/in/kfreitas-sampaio/) |

Este projeto implementa uma infraestrutura completa na AWS usando Terraform, com foco em alta disponibilidade, escalabilidade automática e boas práticas de DevOps.


## 🌟 Visão Geral

Este projeto implementa uma infraestrutura como código (IaC) na AWS utilizando Terraform, seguindo as melhores práticas de DevOps. A infraestrutura é projetada para ser altamente disponível, escalável e segura.

### Principais Características

- Infraestrutura como Código com Terraform
- Alta disponibilidade em múltiplas AZs
- Auto-scaling automático
- Load balancing
- CI/CD com GitHub Actions
- Estado remoto seguro
- Monitoramento integrado

## 🏗️ Arquitetura

### Componentes Principais

1. **VPC (Virtual Private Cloud)**

   - CIDR Block: 10.0.0.0/16
   - Subnets públicas em múltiplas AZs
   - Internet Gateway
   - Route Tables configuradas
   - NAT Gateway para instâncias privadas

2. **Application Load Balancer (ALB)**

   - Distribuição de tráfego entre instâncias
   - Health checks configurados
   - Security Groups para controle de acesso
   - SSL/TLS termination
   - Logging habilitado

3. **Auto Scaling Group (ASG)**
   - Instâncias EC2 auto-escaláveis
   - Launch Template configurado
   - Integração com o ALB
   - Políticas de scaling baseadas em métricas
   - Cooldown periods configurados

## 📁 Estrutura do Projeto

```
├── main.tf                 # Configuração principal do Terraform
├── variables.tf           # Definição de variáveis
├── outputs.tf             # Outputs do projeto
├── backend.tf             # Configuração do backend S3
├── terraform-state/       # Configuração do estado remoto
│   └── main.tf           # Criação do bucket S3 e DynamoDB
├── modules/              # Módulos do projeto
│   ├── vpc/             # Módulo de rede
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/             # Módulo do Load Balancer
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2-asg/         # Módulo de Auto Scaling
│       ├── main.tf
│       └── variables.tf
└── .github/workflows/    # Configurações do GitHub Actions
    └── terraform.yml     # Pipeline de CI/CD
```

## 🚀 Pré-requisitos

### Requisitos de Software

- AWS CLI (versão 2.x)
- Terraform (versão 1.5.0 ou superior)
- Git
- Python 3.8+ (para scripts de automação)

### Requisitos de Conta

- Conta AWS com permissões adequadas
- Acesso ao GitHub
- Credenciais AWS configuradas

### Permissões AWS Necessárias

- IAM
- VPC
- EC2
- S3
- DynamoDB
- CloudWatch
- Auto Scaling

## ⚙️ Configuração Inicial

### 1. Preparar o Estado Remoto

```bash
cd terraform-state
terraform init
terraform apply
```

### 2. Configurar Variáveis de Ambiente

```bash
# No GitHub, configure os seguintes secrets:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

### 3. Inicializar o Projeto

```bash
terraform init
terraform plan
terraform apply
```

### Variáveis do Projeto

| Nome                | Descrição                  | Padrão      | Obrigatório |
| ------------------- | -------------------------- | ----------- | ----------- |
| aws_region          | Região AWS                 | us-east-1   | Não         |
| vpc_cidr_block      | CIDR da VPC                | 10.0.0.0/16 | Não         |
| public_subnet_count | Número de subnets públicas | 2           | Não         |
| environment         | Ambiente (dev/prod)        | dev         | Não         |
| instance_type       | Tipo da instância EC2      | t3.micro    | Não         |

## 🔧 Módulos

### VPC

- Cria uma VPC isolada
- Configura subnets públicas e privadas
- Estabelece conectividade com a Internet
- Configura NAT Gateway
- Gerencia Route Tables

### ALB (Application Load Balancer)

- Distribui tráfego entre instâncias
- Configura health checks
- Gerencia security groups
- Habilita SSL/TLS
- Configura logging

### EC2-ASG (Auto Scaling Group)

- Gerencia instâncias EC2
- Escala automaticamente baseado em demanda
- Integra com o ALB
- Configura políticas de scaling
- Gerencia launch templates

## 🔄 CI/CD

### Pipeline GitHub Actions

1. **Pull Request**:

   - Terraform Init
   - Terraform Plan
   - Validação de configuração
   - Verificação de segurança

2. **Main**:

   - Terraform Init
   - Terraform Plan
   - Terraform Apply
   - Notificação de sucesso

3. **Cleanup**:
   - Destruição automática em caso de falha
   - Notificação de falhas
   - Criação de issues

## 🛡️ Segurança

### Medidas Implementadas

- Bucket S3 com criptografia
- Sem acesso público aos recursos
- Security Groups restritivos
- Estado do Terraform protegido
- IAM roles com privilégios mínimos
- VPC com subnets isoladas
- SSL/TLS em todas as comunicações

### Boas Práticas

- Rotação regular de credenciais
- Auditoria de segurança
- Monitoramento de acesso
- Backup regular
- Atualizações de segurança

## 📊 Monitoramento

### Métricas Monitoradas

- Health checks do ALB
- Métricas do Auto Scaling
- Logs de acesso do ALB
- Estado das instâncias EC2
- Uso de CPU e memória
- Latência de rede
- Erros de aplicação

### Alertas Configurados

- Falhas de health check
- Escalonamento de instâncias
- Erros de aplicação
- Problemas de rede
- Uso de recursos

## 🔧 Manutenção

### Tarefas Regulares

- Backup do estado do Terraform
- Atualização de AMIs
- Revisão de security groups
- Monitoramento de custos
- Atualização de dependências

### Procedimentos de Backup

- Backup diário do estado
- Backup de configurações
- Backup de logs
- Backup de dados

## 🚫 Solução de Problemas

### Problemas Comuns

1. **Estado Bloqueado**:

   ```bash
   terraform force-unlock LOCK_ID
   ```

2. **Falha no Apply**:

   - Verifique as credenciais AWS
   - Confirme limites de serviço
   - Revise logs de erro

3. **Problemas de Rede**:
   - Verifique configurações de VPC
   - Confirme rotas e security groups
   - Teste conectividade

### Logs e Diagnóstico

- Logs do Terraform
- Logs do ALB
- Logs do EC2
- Métricas do CloudWatch

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

### Padrões de Código

- Siga as convenções do Terraform
- Documente todas as alterações
- Inclua testes quando possível
- Mantenha o código limpo e organizado

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📞 Suporte

Para suporte:

- Abra uma issue no GitHub
- Contate a equipe de desenvolvimento
- Consulte a documentação
- Participe da comunidade

---

Desenvolvido com ❤️ pela equipe Squad5 do Bootcamp DevOps
