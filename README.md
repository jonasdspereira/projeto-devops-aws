# Projeto DevOps AWS - Infraestrutura como Código

Este projeto implementa uma infraestrutura completa na AWS usando Terraform, com foco em alta disponibilidade e escalabilidade automática.

## 🏗️ Arquitetura

O projeto cria a seguinte infraestrutura:

1. **VPC (Virtual Private Cloud)**

   - Subnets públicas em múltiplas AZs
   - Internet Gateway
   - Route Tables configuradas

2. **Application Load Balancer (ALB)**

   - Distribuição de tráfego entre instâncias
   - Health checks configurados
   - Security Groups para controle de acesso

3. **Auto Scaling Group (ASG)**
   - Instâncias EC2 auto-escaláveis
   - Launch Template configurado
   - Integração com o ALB

## 📁 Estrutura do Projeto

```
├── main.tf # Arquivo principal de configuração
├── variables.tf # Definição de variáveis
├── outputs.tf # Outputs do projeto
├── backend.tf # Configuração do backend S3
├── terraform-state/ # Configuração do estado remoto
│ └── main.tf # Criação do bucket S3 e DynamoDB
├── modules/ # Módulos do projeto
│ ├── vpc/ # Módulo de rede
│ │ ├── main.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ ├── alb/ # Módulo do Load Balancer
│ │ ├── main.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ └── ec2-asg/ # Módulo de Auto Scaling
│ ├── main.tf
│ └── variables.tf
└── .github/workflows/ # Configurações do GitHub Actions
└── terraform.yml # Pipeline de CI/CD
```

## 🚀 Como Usar

### Pré-requisitos

- AWS CLI configurado
- Terraform instalado (versão 1.5.0 ou superior)
- Conta AWS com permissões adequadas
- GitHub Actions configurado (para CI/CD)

### Configuração Inicial

1. **Preparar o Estado Remoto**

```bash
cd terraform-state
terraform init
terraform apply
```

2. **Configurar Variáveis de Ambiente**

```bash
# No GitHub, configure os seguintes secrets:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

3. **Inicializar o Projeto**

```bash
terraform init
terraform plan
terraform apply
```

### Variáveis do Projeto

| Nome                | Descrição                  | Padrão      |
| ------------------- | -------------------------- | ----------- |
| aws_region          | Região AWS                 | us-east-1   |
| vpc_cidr_block      | CIDR da VPC                | 10.0.0.0/16 |
| public_subnet_count | Número de subnets públicas | 2           |

## 🔧 Módulos

### VPC

- Cria uma VPC isolada
- Configura subnets públicas
- Estabelece conectividade com a Internet

### ALB (Application Load Balancer)

- Distribui tráfego entre instâncias
- Configura health checks
- Gerencia security groups

### EC2-ASG (Auto Scaling Group)

- Gerencia instâncias EC2
- Escala automaticamente baseado em demanda
- Integra com o ALB

## 📤 Outputs

| Nome         | Descrição                 |
| ------------ | ------------------------- |
| alb_dns_name | DNS name do Load Balancer |
| vpc_id       | ID da VPC criada          |

## 🔒 Backend

O estado do Terraform é armazenado remotamente em:

- **S3 Bucket**: squad5-desafio-state
- **DynamoDB Table**: terraform-state-lock
- **Região**: us-east-1

## 👥 CI/CD

O projeto usa GitHub Actions para:

- Validar alterações em Pull Requests
- Aplicar mudanças automaticamente na main
- Destruir recursos em caso de falha

### Pipeline

1. **Pull Request**:

   - Terraform Init
   - Terraform Plan
   - Validação de configuração

2. **Main**:

   - Terraform Init
   - Terraform Plan
   - Terraform Apply

3. **Cleanup**:
   - Destruição automática em caso de falha
   - Notificação de falhas
   - Criação de issues para atenção manual

## 🛡️ Segurança

- Bucket S3 com criptografia
- Sem acesso público aos recursos
- Security Groups restritivos
- Estado do Terraform protegido

## 🔍 Monitoramento

- Health checks do ALB
- Métricas do Auto Scaling
- Logs de acesso do ALB
- Estado das instâncias EC2

## 📝 Notas Importantes

1. **Custos**:

   - Recursos AWS podem gerar custos
   - Auto Scaling pode criar múltiplas instâncias
   - Monitore seus gastos regularmente

2. **Segurança**:

   - Mantenha as credenciais AWS seguras
   - Revise as políticas de segurança
   - Atualize regularmente as AMIs

3. **Manutenção**:
   - Faça backup regular do estado
   - Monitore os recursos criados
   - Mantenha o Terraform atualizado

## 🚫 Problemas Comuns

1. **Estado Bloqueado**:

   ```bash
   # Limpar lock do estado
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

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT.

## 📞 Suporte

Para suporte, abra uma issue no GitHub ou contate a equipe de desenvolvimento.
